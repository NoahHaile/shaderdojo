CREATE TABLE users
(
    id         SERIAL PRIMARY KEY,
    open_id    VARCHAR(255) NOT NULL UNIQUE,
    email      VARCHAR(1024),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_open_id ON users(open_id);