package tech.shaderdojo.backend.models;

import jakarta.persistence.*;

@Entity
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String code;
    private String content;

    @ManyToOne
    @JoinColumn(name = "problem", nullable = false)
    private Problem problem;

    @ManyToOne
    @JoinColumn(name = "account", nullable = false)
    private Account account;

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public void setId(String id) {
        this.id = id;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setProblem(Problem problem) {
        this.problem = problem;
    }

    public Problem getProblem() {
        return problem;
    }
    public String getId() {
        return id;
    }

    public String getCode() {
        return code;
    }

    public String getContent() {
        return content;
    }
}
