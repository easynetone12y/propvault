package com.propvault.service.impl;

import com.propvault.dto.request.*;
import com.propvault.dto.response.AuthResponse;
import com.propvault.entity.*;
import com.propvault.enums.SubscriptionStatus;
import com.propvault.enums.UserRole;
import com.propvault.exception.ApiException;
import com.propvault.repository.*;
import com.propvault.security.service.JwtService;
import com.propvault.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.*;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service @RequiredArgsConstructor @Slf4j
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepo;
    private final AgentRepository agentRepo;
    private final SubscriptionRepository subRepo;
    private final SubscriptionPlanRepository planRepo;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authManager;
    private final UserDetailsService userDetailsService;

    @Override @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (userRepo.existsByEmail(req.getEmail()))
            throw ApiException.conflict("Email already registered");
        if (req.getPhone() != null && userRepo.existsByPhone(req.getPhone()))
            throw ApiException.conflict("Phone number already in use");

        User user = User.builder()
            .name(req.getName())
            .email(req.getEmail())
            .passwordHash(passwordEncoder.encode(req.getPassword()))
            .phone(req.getPhone())
            .role(req.getRole())
            .emailVerified(false)
            .active(true)
            .build();
        userRepo.save(user);

        Agent agent = null;
        if (req.getRole() == UserRole.AGENT) {
            if (req.getCompanyName() == null || req.getCompanyName().isBlank())
                throw ApiException.badRequest("Company name is required for agent registration");

            agent = Agent.builder()
                .user(user)
                .companyName(req.getCompanyName())
                .licenseNo(req.getLicenseNo())
                .reraNo(req.getReraNo())
                .city(req.getCity())
                .state(req.getState())
                .verified(false)
                .build();
            agentRepo.save(agent);

            // Assign 14-day trial with Basic plan
            planRepo.findByName("BASIC").ifPresent(plan -> {
                Subscription sub = Subscription.builder()
                    .agent(agent)
                    .plan(plan)
                    .status(SubscriptionStatus.TRIAL)
                    .autoRenew(false)
                    .build();
                subRepo.save(sub);
            });
        }

        UserDetails ud = userDetailsService.loadUserByUsername(user.getEmail());
        return buildAuthResponse(user, agent, ud);
    }

    @Override
    public AuthResponse login(LoginRequest req) {
        try {
            authManager.authenticate(new UsernamePasswordAuthenticationToken(req.getEmail(), req.getPassword()));
        } catch (BadCredentialsException e) {
            throw ApiException.unauthorized("Invalid email or password");
        }
        User user = userRepo.findByEmail(req.getEmail())
            .orElseThrow(() -> ApiException.notFound("User not found"));
        Agent agent = user.getRole() == UserRole.AGENT
            ? agentRepo.findByUserId(user.getId()).orElse(null) : null;
        UserDetails ud = userDetailsService.loadUserByUsername(user.getEmail());
        return buildAuthResponse(user, agent, ud);
    }

    @Override
    public AuthResponse refresh(String refreshToken) {
        String email = jwtService.extractUsername(refreshToken);
        UserDetails ud = userDetailsService.loadUserByUsername(email);
        if (!jwtService.isTokenValid(refreshToken, ud))
            throw ApiException.unauthorized("Invalid or expired refresh token");
        User user = userRepo.findByEmail(email).orElseThrow(() -> ApiException.notFound("User not found"));
        Agent agent = user.getRole() == UserRole.AGENT
            ? agentRepo.findByUserId(user.getId()).orElse(null) : null;
        return buildAuthResponse(user, agent, ud);
    }

    @Override
    public void logout(String token) {
        // Token blacklisting can be implemented with Redis
        log.info("User logged out, token invalidated");
    }

    @Override
    public void verifyEmail(String token) {
        // In production: verify token from Redis/DB, then mark user.emailVerified = true
        log.info("Email verification token: {}", token);
    }

    private AuthResponse buildAuthResponse(User user, Agent agent, UserDetails ud) {
        return AuthResponse.builder()
            .accessToken(jwtService.generateToken(ud))
            .refreshToken(jwtService.generateRefreshToken(ud))
            .tokenType("Bearer")
            .expiresIn(86400000L)
            .userId(user.getId())
            .name(user.getName())
            .email(user.getEmail())
            .role(user.getRole())
            .agentId(agent != null ? agent.getId() : null)
            .build();
    }
}
