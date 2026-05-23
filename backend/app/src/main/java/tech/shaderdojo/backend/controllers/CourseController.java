package tech.shaderdojo.backend.controllers;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import tech.shaderdojo.backend.dtos.CourseDetailResponse;
import tech.shaderdojo.backend.dtos.CourseResponse;
import tech.shaderdojo.backend.dtos.CreateCourseRequest;
import tech.shaderdojo.backend.models.Course;
import tech.shaderdojo.backend.repositories.CourseRepository;
import tech.shaderdojo.backend.repositories.LessonRepository;
import tech.shaderdojo.backend.utils.AdminAuth;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/courses")
public class CourseController {

    private final CourseRepository courseRepository;
    private final LessonRepository lessonRepository;
    private final String apiKey;

    public CourseController(CourseRepository courseRepository,
                            LessonRepository lessonRepository,
                            @Value("${api.key}") String apiKey) {
        this.courseRepository = courseRepository;
        this.lessonRepository = lessonRepository;
        this.apiKey = apiKey;
    }

    @GetMapping
    public ResponseEntity<List<CourseDetailResponse>> list() {
        List<CourseDetailResponse> out = courseRepository
                .findAllByOrderByDisplayOrderAscTitleAsc()
                .stream()
                .map(c -> CourseDetailResponse.from(
                        c, lessonRepository.findAllByCourseIdOrderByDisplayOrderAscTitleAsc(c.getId())))
                .toList();
        return ResponseEntity.ok(out);
    }

    @GetMapping("/{slug}")
    public ResponseEntity<CourseDetailResponse> detail(@PathVariable String slug) {
        Optional<Course> courseOpt = courseRepository.findBySlug(slug);
        if (courseOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        Course course = courseOpt.get();
        var lessons = lessonRepository.findAllByCourseIdOrderByDisplayOrderAscTitleAsc(course.getId());
        return ResponseEntity.ok(CourseDetailResponse.from(course, lessons));
    }

    @PostMapping
    public ResponseEntity<CourseResponse> create(@RequestBody CreateCourseRequest req,
                                                 @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        if (req == null || req.slug() == null || req.title() == null) {
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        }
        Course c = new Course();
        c.setSlug(req.slug());
        c.setTitle(req.title());
        c.setDescription(req.description());
        c.setDisplayOrder(req.displayOrder() == null ? 0 : req.displayOrder());
        return new ResponseEntity<>(CourseResponse.from(courseRepository.save(c)), HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CourseResponse> update(@PathVariable String id,
                                                 @RequestBody CreateCourseRequest req,
                                                 @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        Optional<Course> existingOpt = courseRepository.findById(id);
        if (existingOpt.isEmpty()) return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        Course existing = existingOpt.get();
        if (req.slug() != null) existing.setSlug(req.slug());
        if (req.title() != null) existing.setTitle(req.title());
        if (req.description() != null) existing.setDescription(req.description());
        if (req.displayOrder() != null) existing.setDisplayOrder(req.displayOrder());
        return ResponseEntity.ok(CourseResponse.from(courseRepository.save(existing)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id,
                                       @RequestHeader("Admin-Authorization") String token) {
        if (!AdminAuth.matches(token, apiKey)) return new ResponseEntity<>(HttpStatus.UNAUTHORIZED);
        if (!courseRepository.existsById(id)) return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        courseRepository.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
