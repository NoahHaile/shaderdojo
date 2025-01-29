package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.Account;

public record AccountResponse(
        String username,
        String email,
        String country,
        String bio
) {
    public AccountResponse(Account account) {
        this(account.getUsername(), account.getEmail(), account.getCountry(), account.getBio());
    }
}
