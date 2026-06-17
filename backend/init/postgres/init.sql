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
-- category is freeform (admin convention). UI groups courses by this column.
-- difficulty is one of: 'beginner' | 'intermediate' | 'advanced'.
-- display_order sorts courses within a category.
-- under_review marks a course as not-yet-finished content; the frontend shows an
-- "Under review" tag. Purely informational, it does not gate access.
CREATE TABLE course
(
    id            VARCHAR(36) PRIMARY KEY DEFAULT (gen_random_uuid()::text),
    slug          VARCHAR(128) UNIQUE NOT NULL,
    title         VARCHAR(256) NOT NULL,
    description   TEXT,
    category      VARCHAR(64) NOT NULL DEFAULT 'Fundamentals',
    difficulty    VARCHAR(16) NOT NULL DEFAULT 'beginner',
    display_order INT NOT NULL DEFAULT 0,
    under_review  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_course_category_order ON course (category, display_order);

-- ---------- lesson ----------
-- description is HTML (sanitized in the frontend).
-- slug is a YouTube-style 11-char base64url id, unique per course.
-- hashed_answer NULL = awaiting `POST /app/lessons/recompute-hashes` after seed boot.
-- concierge_hint is optional plain-text guidance injected into the Concierge AI's
-- system prompt for this lesson only (e.g. "go gentle, this step is hard"). NULL = none.
CREATE TABLE lesson
(
    id                        VARCHAR(36) PRIMARY KEY DEFAULT (gen_random_uuid()::text),
    course_id                 VARCHAR(36) NOT NULL REFERENCES course (id) ON DELETE CASCADE,
    slug                      VARCHAR(128) NOT NULL,
    display_order             INT NOT NULL DEFAULT 0,
    title                     VARCHAR(256) NOT NULL,
    description               TEXT,
    starter_vertex_shader     TEXT,
    starter_fragment_shader   TEXT,
    canonical_fragment_shader TEXT,
    concierge_hint            TEXT,
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

-- Seed data lives in `seed-*.sql` files alongside this one. Postgres docker
-- entrypoint runs every *.sql in alphabetical order, so courses load before
-- their lessons. Edit each family file independently.
