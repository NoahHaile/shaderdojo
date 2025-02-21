package com.clickedtools.auth.user;

public record RegisterRequest(
        String email,
        String username,
        String password,
        String captcha,
        String captchaHash
) {
}
