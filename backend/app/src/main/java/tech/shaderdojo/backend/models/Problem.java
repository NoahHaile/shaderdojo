package tech.shaderdojo.backend.models;

import jakarta.persistence.*;

import java.util.List;

@Entity
public class Problem {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;
    private String hashedAnswer;

    public void setId(String id) {
        this.id = id;
    }

    public void setHashedAnswer(String hashedAnswer) {
        this.hashedAnswer = hashedAnswer;
    }

    public String getId() {
        return id;
    }

    public String getHashedAnswer() {
        return hashedAnswer;
    }
}
