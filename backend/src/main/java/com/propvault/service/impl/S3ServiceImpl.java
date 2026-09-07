package com.propvault.service.impl;

import com.propvault.exception.ApiException;
import com.propvault.service.S3Service;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;

import java.io.IOException;
import java.time.Duration;
import java.util.UUID;

@Service @Slf4j
public class S3ServiceImpl implements S3Service {

    private final S3Client s3Client;
    private final S3Presigner presigner;

    @Value("${propvault.aws.bucket-name}") private String bucket;
    @Value("${propvault.aws.cloudfront-domain:}") private String cloudfrontDomain;

    public S3ServiceImpl(S3Client s3Client, S3Presigner presigner) {
        this.s3Client = s3Client; this.presigner = presigner;
    }

    @Override
    public String uploadMedia(MultipartFile file, String folder) {
        String key = folder + "/" + UUID.randomUUID() + "_" + file.getOriginalFilename();
        try {
            s3Client.putObject(PutObjectRequest.builder()
                .bucket(bucket).key(key)
                .contentType(file.getContentType())
                .contentLength(file.getSize())
                .build(), RequestBody.fromBytes(file.getBytes()));

            if (!cloudfrontDomain.isBlank()) return "https://" + cloudfrontDomain + "/" + key;
            return "https://" + bucket + ".s3.amazonaws.com/" + key;
        } catch (IOException e) {
            log.error("S3 upload failed: {}", e.getMessage());
            throw ApiException.badRequest("File upload failed: " + e.getMessage());
        }
    }

    @Override
    public void delete(String s3Key) {
        try {
            s3Client.deleteObject(DeleteObjectRequest.builder().bucket(bucket).key(s3Key).build());
        } catch (Exception e) {
            log.warn("S3 delete failed for key {}: {}", s3Key, e.getMessage());
        }
    }

    @Override
    public String getPresignedUrl(String s3Key, int expiryMinutes) {
        return presigner.presignGetObject(GetObjectPresignRequest.builder()
            .signatureDuration(Duration.ofMinutes(expiryMinutes))
            .getObjectRequest(GetObjectRequest.builder().bucket(bucket).key(s3Key).build())
            .build()).url().toString();
    }
}
