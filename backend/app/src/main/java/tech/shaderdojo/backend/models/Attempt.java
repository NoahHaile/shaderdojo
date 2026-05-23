package tech.shaderdojo.backend.models;

import jakarta.persistence.*;
import tech.shaderdojo.backend.models.enums.AttemptStatus;

@Entity
public class Attempt {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "lesson", nullable = false)
    private Lesson lesson;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "account", nullable = false)
    private Account account;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AttemptStatus status;

    public Attempt() {}

    public Attempt(Lesson lesson, Account account, AttemptStatus status) {
        this.lesson = lesson;
        this.account = account;
        this.status = status;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Lesson getLesson() { return lesson; }
    public void setLesson(Lesson lesson) { this.lesson = lesson; }

    public Account getAccount() { return account; }
    public void setAccount(Account account) { this.account = account; }

    public AttemptStatus getStatus() { return status; }
    public void setStatus(AttemptStatus status) { this.status = status; }
}
