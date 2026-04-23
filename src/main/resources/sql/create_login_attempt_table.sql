CREATE TABLE IF NOT EXISTS login_attempt (
    user_id VARCHAR(100) NOT NULL,
    client_ip VARCHAR(45) NOT NULL,
    fail_count INT NOT NULL DEFAULT 0,
    lock_until DATETIME NULL,
    last_failed_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, client_ip),
    INDEX idx_login_attempt_lock_until (lock_until),
    INDEX idx_login_attempt_updated_at (updated_at)
);
