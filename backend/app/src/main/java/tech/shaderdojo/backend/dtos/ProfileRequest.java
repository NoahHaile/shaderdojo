package tech.shaderdojo.backend.dtos;

public record ProfileRequest(
        String email,
        String country,
        String bio
) {
}
