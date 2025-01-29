package com.clickedtools.auth.user;

public record LoginRequest(
        String username,
        String password
) {
}
