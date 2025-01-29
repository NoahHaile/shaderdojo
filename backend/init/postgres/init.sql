CREATE TABLE account
(
    id         VARCHAR(512) PRIMARY KEY,
    username   VARCHAR(1024) UNIQUE NOT NULL,
    password   VARCHAR(1024) NOT NULL,

    email      VARCHAR(1024),
    country    VARCHAR(1024),
    bio        VARCHAR(1024),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_account_username ON account (username);

CREATE TABLE problem
(
    id            VARCHAR(512) PRIMARY KEY,
    hashed_answer VARCHAR(1024),
    title         VARCHAR(1024),
    content       VARCHAR(4096),
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE comment
(
    id         VARCHAR(512) PRIMARY KEY,
    code       VARCHAR(4096),
    content    VARCHAR(512),
    account    VARCHAR(512) REFERENCES account (id),
    problem    VARCHAR(512) REFERENCES problem (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE attempt
(
    id         VARCHAR(512) PRIMARY KEY,
    status     VARCHAR(512),
    account    VARCHAR(512) REFERENCES account (id),
    problem    VARCHAR(512) REFERENCES problem (id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);