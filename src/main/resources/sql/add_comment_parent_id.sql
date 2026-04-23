-- 댓글 대댓글 기능을 위한 parent_id 컬럼 추가
-- parent_id NULL = 최상위 댓글
-- parent_id NOT NULL = 대댓글, 값은 최상위 댓글의 comment_no

ALTER TABLE comment
    ADD COLUMN parent_id INT DEFAULT NULL AFTER review_no,
    ADD INDEX idx_comment_parent (parent_id),
    ADD CONSTRAINT fk_comment_parent
        FOREIGN KEY (parent_id) REFERENCES comment(comment_no) ON DELETE CASCADE;
