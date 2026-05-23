package tech.shaderdojo.backend.auth;

import com.nimbusds.jose.jwk.source.ImmutableSecret;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.actuate.autoconfigure.security.servlet.EndpointRequest;
import org.springframework.boot.actuate.health.HealthEndpoint;
import org.springframework.boot.actuate.info.InfoEndpoint;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.nio.charset.StandardCharsets;
import java.util.List;

import static org.springframework.security.web.util.matcher.AntPathRequestMatcher.antMatcher;

@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Value("${jwt.key}")
    private String jwtKey;

    @Value("${app.cors.allowed-origins:}")
    private List<String> corsAllowedOrigins;

    @PostConstruct
    void validateJwtKey() {
        if (jwtKey == null || jwtKey.getBytes(StandardCharsets.UTF_8).length < 32) {
            throw new IllegalStateException(
                    "jwt.key must be set and at least 32 bytes (256 bits) for HS256. " +
                    "Configure JWT_KEY env var with a strong random value.");
        }
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(authorize -> authorize
                        // Actuator: use the idiomatic helper so Spring Boot's separate handler
                        // mapping is matched correctly.
                        .requestMatchers(EndpointRequest.to(HealthEndpoint.class, InfoEndpoint.class)).permitAll()

                        // All other matchers use AntPathRequestMatcher explicitly. We avoid the
                        // bare requestMatchers(String...) form because Spring Security 6.4's
                        // MVC auto-detection silently misbehaves when Actuator's HandlerMapping
                        // is on the classpath, leaving permitAll matchers as no-ops.
                        .requestMatchers(antMatcher(HttpMethod.GET, "/courses")).permitAll()
                        .requestMatchers(antMatcher(HttpMethod.GET, "/courses/**")).permitAll()
                        .requestMatchers(antMatcher(HttpMethod.GET, "/lessons/*")).permitAll()
                        .requestMatchers(antMatcher(HttpMethod.GET, "/lessons/*/solution")).permitAll()
                        .requestMatchers(antMatcher(HttpMethod.GET, "/comments/**")).permitAll()

                        // Admin batch endpoint — gated by constant-time Admin-Authorization check in the controller.
                        .requestMatchers(antMatcher(HttpMethod.POST, "/lessons/recompute-hashes")).permitAll()

                        // Everything else (verify, comment POST, admin CRUD) requires a JWT.
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 ->
                        oauth2.jwt(jwt -> jwt
                                .jwtAuthenticationConverter(jwtAuthenticationConverter())
                                .decoder(jwtDecoder())
                        )
                )
                .build();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        var config = new CorsConfiguration();
        if (corsAllowedOrigins != null && !corsAllowedOrigins.isEmpty()) {
            config.setAllowedOrigins(corsAllowedOrigins);
        } else {
            config.addAllowedOriginPattern("*");
        }
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type", "Admin-Authorization"));
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        return new JwtAuthenticationConverter();
    }

    @Bean
    JwtDecoder jwtDecoder() {
        var secret = new ImmutableSecret<>(jwtKey.getBytes(StandardCharsets.UTF_8)).getSecretKey();
        return NimbusJwtDecoder.withSecretKey(secret)
                .macAlgorithm(MacAlgorithm.HS256)
                .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
