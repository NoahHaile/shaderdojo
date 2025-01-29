package tech.shaderdojo.backend.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import tech.shaderdojo.backend.models.Account;

public interface AccountRepository extends JpaRepository<Account, String> {
}
