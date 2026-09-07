package com.propvault.service;

import com.propvault.dto.request.*;
import com.propvault.dto.response.AuthResponse;

public interface AuthService {
    AuthResponse register(RegisterRequest request);
    AuthResponse login(LoginRequest request);
    AuthResponse refresh(String refreshToken);
    void logout(String token);
    void verifyEmail(String token);
}
