package tech.shaderdojo.backend.dtos;

import tech.shaderdojo.backend.models.enums.AttemptStatus;

public record AttemptResponse(
        int count,
        AttemptStatus status
) {
}
