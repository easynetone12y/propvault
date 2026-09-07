package com.propvault.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class ApiException extends RuntimeException {
    private final HttpStatus status;
    public ApiException(String message, HttpStatus status) {
        super(message);
        this.status = status;
    }
    public static ApiException notFound(String msg)    { return new ApiException(msg, HttpStatus.NOT_FOUND); }
    public static ApiException forbidden(String msg)   { return new ApiException(msg, HttpStatus.FORBIDDEN); }
    public static ApiException badRequest(String msg)  { return new ApiException(msg, HttpStatus.BAD_REQUEST); }
    public static ApiException conflict(String msg)    { return new ApiException(msg, HttpStatus.CONFLICT); }
    public static ApiException unauthorized(String msg){ return new ApiException(msg, HttpStatus.UNAUTHORIZED); }
}
