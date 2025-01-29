package tech.shaderdojo.backend.models;

import jakarta.persistence.*;
import tech.shaderdojo.backend.models.enums.AttemptStatus;

@Entity
public class Attempt {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne
    @JoinColumn(name = "problem", nullable = false)
    private Problem problem;

    @ManyToOne
    @JoinColumn(name = "account", nullable = false)
    private Account account;

    private AttemptStatus status;

    public Attempt() {
    }

    public Attempt(Problem problem, Account account, AttemptStatus status) {
        this.problem = problem;
        this.account = account;
        this.status = status;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setProblem(Problem problem) {
        this.problem = problem;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public void setStatus(AttemptStatus status) {
        this.status = status;
    }

    public String getId() {
        return id;
    }

    public Problem getProblem() {
        return problem;
    }

    public Account getAccount() {
        return account;
    }

    public AttemptStatus getStatus() {
        return status;
    }
}
