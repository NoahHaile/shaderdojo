package tech.shaderdojo.backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import tech.shaderdojo.backend.models.Problem;

public interface ProblemRepository extends JpaRepository<Problem, String> {
}
