package com.propvault.controller;

import com.propvault.dto.request.PropertyRequest;
import com.propvault.dto.response.*;
import com.propvault.enums.PropertyPurpose;
import com.propvault.enums.PropertyType;
import com.propvault.service.PropertyService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.*;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.math.BigDecimal;
import java.util.*;

@RestController @RequestMapping("/properties") @RequiredArgsConstructor
@Tag(name = "Properties")
public class PropertyController {
    private final PropertyService propertyService;

    @GetMapping("/search")
    public ResponseEntity<PagedResponse<PropertyResponse>> search(
            @RequestParam(required=false) String city,
            @RequestParam(required=false) String locality,
            @RequestParam(required=false) PropertyType type,
            @RequestParam(required=false) PropertyPurpose purpose,
            @RequestParam(required=false) Integer bedrooms,
            @RequestParam(required=false) BigDecimal minPrice,
            @RequestParam(required=false) BigDecimal maxPrice,
            @RequestParam(required=false) BigDecimal minArea,
            @RequestParam(required=false) BigDecimal maxArea,
            @RequestParam(defaultValue="false") boolean featuredFirst,
            @PageableDefault(size=20) Pageable pageable) {
        return ResponseEntity.ok(propertyService.search(city, locality, type, purpose,
            bedrooms, minPrice, maxPrice, minArea, maxArea, featuredFirst, pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PropertyResponse> getById(@PathVariable UUID id) {
        return ResponseEntity.ok(propertyService.getById(id));
    }

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<PropertyResponse> create(
            @Valid @RequestPart PropertyRequest request,
            @RequestPart(required=false) List<MultipartFile> images,
            @RequestPart(required=false) MultipartFile video) {
        return ResponseEntity.ok(propertyService.create(request, images, video));
    }

    @PutMapping(value="/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<PropertyResponse> update(
            @PathVariable UUID id,
            @Valid @RequestPart PropertyRequest request,
            @RequestPart(required=false) List<MultipartFile> newImages) {
        return ResponseEntity.ok(propertyService.update(id, request, newImages));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        propertyService.delete(id); return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{id}/media/{mediaId}")
    @PreAuthorize("hasRole('AGENT')")
    public ResponseEntity<Void> deleteMedia(@PathVariable UUID id, @PathVariable UUID mediaId) {
        propertyService.deleteMedia(id, mediaId); return ResponseEntity.noContent().build();
    }
}
