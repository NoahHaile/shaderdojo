package tech.shaderdojo.backend.utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

public final class AdminAuth {
    private AdminAuth() {}

    public static boolean matches(String provided, String expected) {
        if (provided == null || expected == null) return false;
        byte[] a = provided.getBytes(StandardCharsets.UTF_8);
        byte[] b = expected.getBytes(StandardCharsets.UTF_8);
        if (a.length != b.length) return false;
        return MessageDigest.isEqual(a, b);
    }
}
