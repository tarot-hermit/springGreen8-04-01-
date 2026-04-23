-- ============================================================
-- springGreen8 누락 테이블 전체 DDL
-- 실행 전: MySQL Workbench에서 springGreen8 DB 선택 후 실행
-- ============================================================

USE springgreen8;

-- ── 1. users 테이블에 카카오 로그인 컬럼 추가 ──────────────────
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS kakao_id       VARCHAR(100) DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS login_provider VARCHAR(20)  DEFAULT NULL;

-- ── 2. movie ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS movie (
    movie_no      INT AUTO_INCREMENT PRIMARY KEY,
    tmdb_id       INT          NOT NULL UNIQUE,
    title         VARCHAR(255) DEFAULT NULL,
    title_en      VARCHAR(255) DEFAULT NULL,
    overview      TEXT         DEFAULT NULL,
    poster_path   VARCHAR(255) DEFAULT NULL,
    backdrop_path VARCHAR(255) DEFAULT NULL,
    release_date  VARCHAR(20)  DEFAULT NULL,
    runtime       INT          DEFAULT NULL,
    vote_average  DECIMAL(4,2) DEFAULT NULL,
    popularity    DECIMAL(10,3) DEFAULT NULL,
    INDEX idx_movie_tmdb_id (tmdb_id)
);

-- ── 3. review ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS review (
    review_no INT AUTO_INCREMENT PRIMARY KEY,
    movie_no  INT            NOT NULL,
    user_no   INT            DEFAULT NULL,   -- NULL = 탈퇴한 사용자
    rating    DECIMAL(2,1)   NOT NULL,
    content   TEXT           NOT NULL,
    spoiler   TINYINT(1)     NOT NULL DEFAULT 0,
    like_cnt  INT            NOT NULL DEFAULT 0,
    reg_date  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_review_user_movie (movie_no, user_no),
    INDEX idx_review_user_no (user_no),
    INDEX idx_review_movie_no (movie_no),
    CONSTRAINT fk_review_movie  FOREIGN KEY (movie_no) REFERENCES movie(movie_no)  ON DELETE CASCADE,
    CONSTRAINT fk_review_user   FOREIGN KEY (user_no)  REFERENCES users(user_no)   ON DELETE SET NULL
);

-- ── 4. review_like ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS review_like (
    user_no   INT NOT NULL,
    review_no INT NOT NULL,
    PRIMARY KEY (user_no, review_no),
    CONSTRAINT fk_like_user   FOREIGN KEY (user_no)   REFERENCES users(user_no)   ON DELETE CASCADE,
    CONSTRAINT fk_like_review FOREIGN KEY (review_no) REFERENCES review(review_no) ON DELETE CASCADE
);

-- ── 5. comment ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS comment (
    comment_no INT AUTO_INCREMENT PRIMARY KEY,
    review_no  INT          NOT NULL,
    parent_id  INT          DEFAULT NULL,
    user_no    INT          DEFAULT NULL,   -- NULL = 탈퇴한 사용자
    content    VARCHAR(500) NOT NULL,
    reg_date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_comment_review_no (review_no),
    INDEX idx_comment_parent (parent_id),
    CONSTRAINT fk_comment_review FOREIGN KEY (review_no) REFERENCES review(review_no)  ON DELETE CASCADE,
    CONSTRAINT fk_comment_parent FOREIGN KEY (parent_id) REFERENCES comment(comment_no) ON DELETE CASCADE,
    CONSTRAINT fk_comment_user   FOREIGN KEY (user_no)   REFERENCES users(user_no)     ON DELETE SET NULL
);

-- ── 6. search_history ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS search_history (
    search_no   INT AUTO_INCREMENT PRIMARY KEY,
    user_no     INT          NOT NULL,
    keyword     VARCHAR(255) NOT NULL,
    result_cnt  INT          NOT NULL DEFAULT 0,
    search_date DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_sh_user_no    (user_no),
    INDEX idx_sh_keyword    (keyword),
    INDEX idx_sh_search_date (search_date),
    CONSTRAINT fk_sh_user FOREIGN KEY (user_no) REFERENCES users(user_no) ON DELETE CASCADE
);

-- ── 7. watchlist ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS watchlist (
    watch_no INT AUTO_INCREMENT PRIMARY KEY,
    user_no  INT         NOT NULL,
    movie_no INT         NOT NULL,
    status   VARCHAR(20) NOT NULL DEFAULT 'WANT',
    reg_date DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_watchlist (user_no, movie_no),
    INDEX idx_wl_user_no (user_no),
    CONSTRAINT fk_wl_user  FOREIGN KEY (user_no)  REFERENCES users(user_no) ON DELETE CASCADE,
    CONSTRAINT fk_wl_movie FOREIGN KEY (movie_no) REFERENCES movie(movie_no) ON DELETE CASCADE
);

-- ── 8. watched (봤어요) ─────────────────────────────────────────
-- mid = users.user_id (VARCHAR), movie_id = movie.tmdb_id (INT)
CREATE TABLE IF NOT EXISTS watched (
    watched_id INT AUTO_INCREMENT PRIMARY KEY,
    mid        VARCHAR(50) NOT NULL,
    movie_id   INT         NOT NULL,
    reg_date   DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_watched (mid, movie_id),
    INDEX idx_watched_mid (mid),
    CONSTRAINT fk_watched_user FOREIGN KEY (mid) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ── 9. collection ──────────────────────────────────────────────
-- mid = users.user_id (VARCHAR)
CREATE TABLE IF NOT EXISTS collection (
    collection_id INT AUTO_INCREMENT PRIMARY KEY,
    mid           VARCHAR(50)  NOT NULL,
    title         VARCHAR(100) NOT NULL,
    description   VARCHAR(300) DEFAULT NULL,
    is_public     TINYINT(1)   NOT NULL DEFAULT 1,
    reg_date      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_collection_mid (mid),
    CONSTRAINT fk_col_user FOREIGN KEY (mid) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ── 10. collection_movie ────────────────────────────────────────
-- movie_id = movie.tmdb_id (INT)
CREATE TABLE IF NOT EXISTS collection_movie (
    collection_id INT NOT NULL,
    movie_id      INT NOT NULL,
    PRIMARY KEY (collection_id, movie_id),
    CONSTRAINT fk_cm_collection FOREIGN KEY (collection_id) REFERENCES collection(collection_id) ON DELETE CASCADE
);

-- ── 11. notification ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS notification (
    noti_id      INT AUTO_INCREMENT PRIMARY KEY,
    receiver_mid VARCHAR(50)   NOT NULL,
    sender_mid   VARCHAR(50)   DEFAULT NULL,
    noti_type    VARCHAR(30)   NOT NULL,
    ref_id       INT           DEFAULT NULL,
    message      VARCHAR(300)  NOT NULL,
    is_read      TINYINT(1)    NOT NULL DEFAULT 0,
    reg_date     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_noti_receiver (receiver_mid),
    INDEX idx_noti_is_read  (is_read),
    CONSTRAINT fk_noti_receiver FOREIGN KEY (receiver_mid) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ── 12. report ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS report (
    report_id    INT AUTO_INCREMENT PRIMARY KEY,
    reporter_mid VARCHAR(50)  NOT NULL,
    target_type  VARCHAR(20)  NOT NULL,   -- 'REVIEW' | 'COMMENT'
    target_id    INT          NOT NULL,
    reason       VARCHAR(200) NOT NULL,
    status       VARCHAR(20)  NOT NULL DEFAULT 'PENDING',
    reg_date     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_report (reporter_mid, target_type, target_id),
    INDEX idx_report_status (status),
    CONSTRAINT fk_report_user FOREIGN KEY (reporter_mid) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ── 13. login_attempt ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS login_attempt (
    user_id        VARCHAR(100) NOT NULL,
    client_ip      VARCHAR(45)  NOT NULL,
    fail_count     INT          NOT NULL DEFAULT 0,
    lock_until     DATETIME     NULL,
    last_failed_at DATETIME     NULL,
    created_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, client_ip),
    INDEX idx_login_attempt_lock_until  (lock_until),
    INDEX idx_login_attempt_updated_at  (updated_at)
);

-- ── 14. withdrawn_user_id (탈퇴 아이디 보존, 재가입 방지) ──────────
CREATE TABLE IF NOT EXISTS withdrawn_user_id (
    user_id    VARCHAR(50) NOT NULL PRIMARY KEY,
    deleted_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ── 15. users 테이블에 is_deleted / deleted_at 컬럼 추가 ────────────
-- (이미 존재하는 경우 오류 무시됨)
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS is_deleted TINYINT(1) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS deleted_at DATETIME   DEFAULT NULL;

-- ── 16. 기본 admin 계정 (없을 경우에만 삽입) ─────────────────────
-- 비밀번호: Admin1234! → SHA-256 해시값
-- SHA-256("Admin1234!") = a7e8c2b9... 아래 값으로 교체 필요시 Python으로 계산:
--   python3 -c "import hashlib; print(hashlib.sha256('Admin1234!'.encode()).hexdigest())"
-- 비밀번호 "Admin1234!" 의 SHA-256 해시
-- 로그인 시 admin / Admin1234! 으로 접속
INSERT IGNORE INTO users (user_id, user_pw, user_name, user_email, user_role)
VALUES (
    'admin',
    '5ce41ada64f1e8ffb0acfaafa622b141438f3a5777785e7f0b830fb73e40d3d6',
    '관리자',
    'admin@springgreen8.com',
    'ADMIN'
);
