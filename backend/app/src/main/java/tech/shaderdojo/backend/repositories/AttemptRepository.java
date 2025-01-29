package tech.shaderdojo.backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import tech.shaderdojo.backend.models.Attempt;

import java.util.List;
import java.util.Optional;

public interface AttemptRepository extends JpaRepository<Attempt, String> {
    Optional<List<Attempt>> findAllByProblemIdAndAccountId(String problemId, String accountId);
}
