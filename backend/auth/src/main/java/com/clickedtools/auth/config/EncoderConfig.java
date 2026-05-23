package com.clickedtools.auth.config;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;

import java.nio.charset.StandardCharsets;

@Configuration
public class EncoderConfig {
    @Value("${jwt.key}")
    private String jwtKey;

    @PostConstruct
    void validateJwtKey() {
        if (jwtKey == null || jwtKey.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException(
                    "jwt.key must be set and at least 32 bytes (256 bits) for HS256. " +
                    "Configure JWT_KEY env var with a strong random value.");
        }
    }

    @Bean
    JwtEncoder jwtEncoder() {
        return new NimbusJwtEncoder(new ImmutableSecret<>(jwtKey.getBytes(StandardCharsets.UTF_8)));
    }
}
