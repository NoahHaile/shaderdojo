package tech.shaderdojo.backend.models;

import jakarta.persistence.*;

@Entity
@Table(name = "lesson")
public class Lesson {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "course_id", nullable = false)
    private Course course;

    @Column(nullable = false)
    private String slug;

    @Column(name = "display_order", nullable = false)
    private int displayOrder = 0;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "starter_vertex_shader", columnDefinition = "TEXT")
    private String starterVertexShader;

    @Column(name = "starter_fragment_shader", columnDefinition = "TEXT")
    private String starterFragmentShader;

    @Column(name = "canonical_fragment_shader", columnDefinition = "TEXT")
    private String canonicalFragmentShader;

    @Column(name = "hashed_answer")
    private String hashedAnswer;

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Course getCourse() { return course; }
    public void setCourse(Course course) { this.course = course; }

    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }

    public int getDisplayOrder() { return displayOrder; }
    public void setDisplayOrder(int displayOrder) { this.displayOrder = displayOrder; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStarterVertexShader() { return starterVertexShader; }
    public void setStarterVertexShader(String s) { this.starterVertexShader = s; }

    public String getStarterFragmentShader() { return starterFragmentShader; }
    public void setStarterFragmentShader(String s) { this.starterFragmentShader = s; }

    public String getCanonicalFragmentShader() { return canonicalFragmentShader; }
    public void setCanonicalFragmentShader(String s) { this.canonicalFragmentShader = s; }

    public String getHashedAnswer() { return hashedAnswer; }
    public void setHashedAnswer(String hashedAnswer) { this.hashedAnswer = hashedAnswer; }
}
