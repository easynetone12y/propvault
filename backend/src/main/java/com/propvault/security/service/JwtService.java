package com.propvault.security.service;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import javax.crypto.SecretKey;
import java.util.*;
import java.util.function.Function;

@Service @Slf4j
public class JwtService {
    @Value("${propvault.jwt.secret}")      private String secret;
    @Value("${propvault.jwt.expiration}")  private long expiration;
    @Value("${propvault.jwt.refresh-expiration}") private long refreshExpiry;

    public String extractUsername(String token) { return extractClaim(token, Claims::getSubject); }
    public <T> T extractClaim(String token, Function<Claims,T> fn) { return fn.apply(getAllClaims(token)); }

    public String generateToken(UserDetails ud) { return generateToken(ud, new HashMap<>()); }
    public String generateToken(UserDetails ud, Map<String,Object> extra) { return build(extra, ud, expiration); }
    public String generateRefreshToken(UserDetails ud) { return build(new HashMap<>(), ud, refreshExpiry); }

    private String build(Map<String,Object> extra, UserDetails ud, long exp) {
        return Jwts.builder().claims(extra).subject(ud.getUsername())
            .issuedAt(new Date()).expiration(new Date(System.currentTimeMillis() + exp))
            .signWith(signingKey()).compact();
    }

    public boolean isTokenValid(String token, UserDetails ud) {
        try { return extractUsername(token).equals(ud.getUsername()) && !isExpired(token); }
        catch (JwtException e) { log.warn("Invalid JWT: {}", e.getMessage()); return false; }
    }

    private boolean isExpired(String t) { return extractClaim(t, Claims::getExpiration).before(new Date()); }
    private Claims getAllClaims(String t) {
        return Jwts.parser().verifyWith(signingKey()).build().parseSignedClaims(t).getPayload();
    }
    private SecretKey signingKey() { return Keys.hmacShaKeyFor(Decoders.BASE64.decode(secret)); }
}
