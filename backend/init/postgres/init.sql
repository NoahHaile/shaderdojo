CREATE DATABASE shader_dojo;
\c shader_dojo;

-- ---------- account ----------
CREATE TABLE account
(
    id         VARCHAR(36) PRIMARY KEY,
    username   VARCHAR(255) UNIQUE NOT NULL,
    password   VARCHAR(255) NOT NULL,
    email      VARCHAR(255),
    country    VARCHAR(128),
    bio        VARCHAR(1024),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_account_username ON account (username);

-- ---------- course ----------
CREATE TABLE course
(
    id            VARCHAR(36) PRIMARY KEY,
    slug          VARCHAR(128) UNIQUE NOT NULL,
    title         VARCHAR(256) NOT NULL,
    description   TEXT,
    display_order INT NOT NULL DEFAULT 0,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_course_display_order ON course (display_order);

-- ---------- lesson ----------
-- A "lesson" is the per-step problem the user solves. hashed_answer NULL = exploratory step (no verification).
CREATE TABLE lesson
(
    id                        VARCHAR(36) PRIMARY KEY,
    course_id                 VARCHAR(36) NOT NULL REFERENCES course (id) ON DELETE CASCADE,
    slug                      VARCHAR(128) NOT NULL,
    display_order             INT NOT NULL DEFAULT 0,
    title                     VARCHAR(256) NOT NULL,
    description               TEXT,
    starter_vertex_shader     TEXT,
    starter_fragment_shader   TEXT,
    canonical_fragment_shader TEXT,
    hashed_answer             VARCHAR(128),
    created_at                TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (course_id, slug)
);

CREATE INDEX idx_lesson_course ON lesson (course_id, display_order);

-- ---------- comment ----------
CREATE TABLE comment
(
    id         VARCHAR(36) PRIMARY KEY,
    code       TEXT,
    content    VARCHAR(512),
    account    VARCHAR(36) REFERENCES account (id) ON DELETE SET NULL,
    lesson     VARCHAR(36) NOT NULL REFERENCES lesson (id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_comment_lesson ON comment (lesson);

-- ---------- attempt ----------
CREATE TABLE attempt
(
    id         VARCHAR(36) PRIMARY KEY,
    status     VARCHAR(32) NOT NULL,
    account    VARCHAR(36) NOT NULL REFERENCES account (id) ON DELETE CASCADE,
    lesson     VARCHAR(36) NOT NULL REFERENCES lesson (id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_attempt_account_lesson ON attempt (account, lesson);

-- ---------- seed: one example course with one lesson ----------
-- Lets you smoke-test the platform end-to-end without first authoring content.
-- Replace via the admin endpoints once you have something real.
INSERT INTO course (id, slug, title, description, display_order) VALUES
    ('11111111-1111-1111-1111-111111111111',
     'getting-started',
     'Getting Started',
     'A single warm-up lesson so you can confirm the platform works on a fresh deploy. Delete this course once you start authoring real content.',
     0);

INSERT INTO lesson (
    id, course_id, slug, display_order, title, description,
    starter_vertex_shader, starter_fragment_shader,
    canonical_fragment_shader, hashed_answer
) VALUES (
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    'hello-green',
    0,
    'Hello, Green Screen',
    'Output a solid green color for every pixel. Edit `gl_FragColor` so that the canvas renders pure green (R=0, G=1, B=0, A=1).',
    'attribute vec2 aVertexPosition;
void main() {
  gl_Position = vec4(aVertexPosition, 0.0, 1.0);
}',
    'void main() {
  // TODO: set gl_FragColor to opaque green.
  gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}',
    'void main() {
  gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}',
    NULL -- populate via admin after running the canonical shader through the validator
);
