package com.propvault.service;

import com.propvault.dto.request.PropertyRequest;
import com.propvault.dto.response.PagedResponse;
import com.propvault.dto.response.PropertyResponse;
import com.propvault.enums.PropertyPurpose;
import com.propvault.enums.PropertyType;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public interface PropertyService {
    PagedResponse<PropertyResponse> search(String city, String locality, PropertyType type,
        PropertyPurpose purpose, Integer bedrooms, BigDecimal minPrice, BigDecimal maxPrice,
        BigDecimal minArea, BigDecimal maxArea, boolean featuredFirst, Pageable pageable);
    PropertyResponse getById(UUID id);
    PropertyResponse create(PropertyRequest request, List<MultipartFile> images, MultipartFile video);
    PropertyResponse update(UUID id, PropertyRequest request, List<MultipartFile> newImages);
    void delete(UUID id);
    void deleteMedia(UUID propertyId, UUID mediaId);
}
