package tech.shaderdojo.backend.dtos;

public record AccountRequest(
        String username,
        String password,
        String oldPassword
) {
}
