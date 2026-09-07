package com.propvault.service;

import org.springframework.web.multipart.MultipartFile;

public interface S3Service {
    String uploadMedia(MultipartFile file, String folder);
    void delete(String s3Key);
    String getPresignedUrl(String s3Key, int expiryMinutes);
}
