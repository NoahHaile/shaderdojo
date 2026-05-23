package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.Comment;

public record CommentResponse(
        String id,
        String code,
        String content,
        String username
) {
    public static CommentResponse from(Comment c) {
        String username = c.getAccount() != null ? c.getAccount().getUsername() : null;
        return new CommentResponse(c.getId(), c.getCode(), c.getContent(), username);
    }
}
