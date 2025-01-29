package tech.shaderdojo.backend.utils;

import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;

public class WebsiteUtils {
    public static String extractUserIdFromJwt(Authentication authentication) {
        if (authentication instanceof JwtAuthenticationToken jwtAuth) {
            return jwtAuth.getToken().getClaim("sub");
        }
        throw new IllegalArgumentException("Invalid authentication type");
    }
}
