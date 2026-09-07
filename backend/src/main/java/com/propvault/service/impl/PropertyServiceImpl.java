package com.propvault.service.impl;

import com.propvault.dto.request.PropertyRequest;
import com.propvault.dto.response.*;
import com.propvault.entity.*;
import com.propvault.enums.*;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.service.PropertyService;
import com.propvault.service.S3Service;
import com.propvault.util.SecurityUtil;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@Service @RequiredArgsConstructor @Slf4j
public class PropertyServiceImpl implements PropertyService {

    private final PropertyRepository propertyRepo;
    private final AgentRepository agentRepo;
    private final SubscriptionRepository subRepo;
    private final SubscriptionPlanRepository planRepo;
    private final S3Service s3Service;
    private final SecurityUtil securityUtil;

    @Override
    public PagedResponse<PropertyResponse> search(String city, String locality, PropertyType type,
            PropertyPurpose purpose, Integer bedrooms, BigDecimal minPrice, BigDecimal maxPrice,
            BigDecimal minArea, BigDecimal maxArea, boolean featuredFirst, Pageable pageable) {

        Specification<Property> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(cb.equal(root.get("status"), PropertyStatus.APPROVED));
            if (city != null)     predicates.add(cb.like(cb.lower(root.get("city")), "%" + city.toLowerCase() + "%"));
            if (locality != null) predicates.add(cb.like(cb.lower(root.get("locality")), "%" + locality.toLowerCase() + "%"));
            if (type != null)     predicates.add(cb.equal(root.get("type"), type));
            if (purpose != null)  predicates.add(cb.equal(root.get("purpose"), purpose));
            if (bedrooms != null) predicates.add(cb.equal(root.get("bedrooms"), bedrooms));
            if (minPrice != null) predicates.add(cb.greaterThanOrEqualTo(root.get("price"), minPrice));
            if (maxPrice != null) predicates.add(cb.lessThanOrEqualTo(root.get("price"), maxPrice));
            if (minArea != null)  predicates.add(cb.greaterThanOrEqualTo(root.get("areaSqFt"), minArea));
            if (maxArea != null)  predicates.add(cb.lessThanOrEqualTo(root.get("areaSqFt"), maxArea));
            if (featuredFirst && query != null)
                query.orderBy(cb.desc(root.get("featured")), cb.desc(root.get("createdAt")));
            return cb.and(predicates.toArray(new Predicate[0]));
        };

        Page<Property> page = propertyRepo.findAll(spec, pageable);
        List<PropertyResponse> content = page.getContent().stream().map(this::toResponse).collect(Collectors.toList());
        return PagedResponse.<PropertyResponse>builder()
            .content(content).page(page.getNumber()).size(page.getSize())
            .totalElements(page.getTotalElements()).totalPages(page.getTotalPages())
            .last(page.isLast()).build();
    }

    @Override
    @Transactional
    public PropertyResponse getById(UUID id) {
        Property p = propertyRepo.findById(id).orElseThrow(() -> ApiException.notFound("Property not found"));
        propertyRepo.incrementViewCount(id);
        return toResponse(p);
    }

    @Override @Transactional
    public PropertyResponse create(PropertyRequest req, List<MultipartFile> images, MultipartFile video) {
        Agent agent = getCurrentAgent();
        validateListingQuota(agent);

        Property p = Property.builder()
            .agent(agent).title(req.getTitle()).description(req.getDescription())
            .type(req.getType()).purpose(req.getPurpose()).status(PropertyStatus.PENDING_REVIEW)
            .price(req.getPrice()).address(req.getAddress()).locality(req.getLocality())
            .city(req.getCity()).state(req.getState()).pincode(req.getPincode())
            .latitude(req.getLatitude()).longitude(req.getLongitude())
            .bedrooms(req.getBedrooms()).bathrooms(req.getBathrooms())
            .floor(req.getFloor()).totalFloors(req.getTotalFloors())
            .areaSqFt(req.getAreaSqFt()).carpetAreaSqFt(req.getCarpetAreaSqFt())
            .buildYear(req.getBuildYear()).furnishingStatus(req.getFurnishingStatus())
            .virtualTourUrl(req.getVirtualTourUrl()).amenities(req.getAmenities())
            .media(new ArrayList<>())
            .build();
        propertyRepo.save(p);

        // Upload images to S3
        if (images != null) {
            for (int i = 0; i < images.size(); i++) {
                String url = s3Service.uploadMedia(images.get(i), "properties/" + p.getId() + "/images");
                PropertyMedia m = PropertyMedia.builder()
                    .property(p).mediaType(MediaType.IMAGE).mediaUrl(url)
                    .primary(i == 0).sortOrder(i).build();
                p.getMedia().add(m);
            }
        }
        if (video != null) {
            String url = s3Service.uploadMedia(video, "properties/" + p.getId() + "/videos");
            p.getMedia().add(PropertyMedia.builder().property(p)
                .mediaType(MediaType.VIDEO).mediaUrl(url).sortOrder(100).build());
        }

        return toResponse(propertyRepo.save(p));
    }

    @Override @Transactional
    public PropertyResponse update(UUID id, PropertyRequest req, List<MultipartFile> newImages) {
        Property p = getOwnedProperty(id);
        p.setTitle(req.getTitle()); p.setDescription(req.getDescription());
        p.setType(req.getType()); p.setPurpose(req.getPurpose());
        p.setPrice(req.getPrice()); p.setLocality(req.getLocality());
        p.setCity(req.getCity()); p.setState(req.getState());
        p.setBedrooms(req.getBedrooms()); p.setBathrooms(req.getBathrooms());
        p.setAreaSqFt(req.getAreaSqFt()); p.setAmenities(req.getAmenities());
        p.setVirtualTourUrl(req.getVirtualTourUrl());
        p.setStatus(PropertyStatus.PENDING_REVIEW); // re-review on edit

        if (newImages != null) {
            int idx = p.getMedia().size();
            for (MultipartFile f : newImages) {
                String url = s3Service.uploadMedia(f, "properties/" + p.getId() + "/images");
                p.getMedia().add(PropertyMedia.builder().property(p)
                    .mediaType(MediaType.IMAGE).mediaUrl(url).sortOrder(idx++).build());
            }
        }
        return toResponse(propertyRepo.save(p));
    }

    @Override @Transactional
    public void delete(UUID id) {
        Property p = getOwnedProperty(id);
        p.getMedia().forEach(m -> { if (m.getS3Key() != null) s3Service.delete(m.getS3Key()); });
        propertyRepo.delete(p);
    }

    @Override @Transactional
    public void deleteMedia(UUID propertyId, UUID mediaId) {
        Property p = getOwnedProperty(propertyId);
        p.getMedia().stream().filter(m -> m.getId().equals(mediaId)).findFirst().ifPresent(m -> {
            if (m.getS3Key() != null) s3Service.delete(m.getS3Key());
            p.getMedia().remove(m);
        });
        propertyRepo.save(p);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private Agent getCurrentAgent() {
        String email = securityUtil.getCurrentUserEmail();
        User user = new User(); user.setEmail(email); // lightweight — agentRepo does the lookup
        return agentRepo.findByUserId(securityUtil.getCurrentUserId())
            .orElseThrow(() -> ApiException.notFound("Agent profile not found"));
    }

    private Property getOwnedProperty(UUID id) {
        Property p = propertyRepo.findById(id).orElseThrow(() -> ApiException.notFound("Property not found"));
        if (!p.getAgent().getId().equals(securityUtil.getCurrentAgentId()))
            throw ApiException.forbidden("You do not own this property");
        return p;
    }

    private void validateListingQuota(Agent agent) {
        subRepo.findByAgentId(agent.getId()).ifPresent(sub -> {
            SubscriptionPlan plan = sub.getPlan();
            if (plan.getMaxListings() == -1) return; // unlimited
            long used = propertyRepo.countByAgentId(agent.getId());
            if (used >= plan.getMaxListings())
                throw ApiException.badRequest(
                    "Listing limit reached (" + plan.getMaxListings() + "). Upgrade your plan to add more.");
        });
    }

    PropertyResponse toResponse(Property p) {
        PropertyResponse r = new PropertyResponse();
        r.setId(p.getId()); r.setTitle(p.getTitle()); r.setDescription(p.getDescription());
        r.setType(p.getType()); r.setPurpose(p.getPurpose()); r.setStatus(p.getStatus());
        r.setPrice(p.getPrice()); r.setPriceLabel(p.getPriceLabel());
        r.setAddress(p.getAddress()); r.setLocality(p.getLocality());
        r.setCity(p.getCity()); r.setState(p.getState()); r.setPincode(p.getPincode());
        r.setLatitude(p.getLatitude()); r.setLongitude(p.getLongitude());
        r.setBedrooms(p.getBedrooms()); r.setBathrooms(p.getBathrooms());
        r.setAreaSqFt(p.getAreaSqFt()); r.setFurnishingStatus(p.getFurnishingStatus());
        r.setFeatured(p.isFeatured()); r.setVirtualTourUrl(p.getVirtualTourUrl());
        r.setAmenities(p.getAmenities()); r.setViewCount(p.getViewCount());
        r.setCreatedAt(p.getCreatedAt()); r.setUpdatedAt(p.getUpdatedAt());

        if (p.getMedia() != null) {
            r.setMedia(p.getMedia().stream().map(m -> {
                MediaResponse mr = new MediaResponse();
                mr.setId(m.getId()); mr.setMediaType(m.getMediaType());
                mr.setMediaUrl(m.getMediaUrl()); mr.setThumbnailUrl(m.getThumbnailUrl());
                mr.setPrimary(m.isPrimary()); mr.setSortOrder(m.getSortOrder());
                return mr;
            }).collect(Collectors.toList()));
        }

        if (p.getAgent() != null) {
            Agent ag = p.getAgent();
            AgentSummaryResponse as = new AgentSummaryResponse();
            as.setId(ag.getId()); as.setCompanyName(ag.getCompanyName());
            as.setCity(ag.getCity()); as.setLogoUrl(ag.getLogoUrl());
            as.setVerified(ag.isVerified());
            if (ag.getUser() != null) {
                as.setName(ag.getUser().getName()); as.setPhone(ag.getUser().getPhone());
            }
            r.setAgent(as);
        }
        return r;
    }
}
