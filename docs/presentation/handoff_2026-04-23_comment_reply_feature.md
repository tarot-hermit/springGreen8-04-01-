# 핸드오프 노트 — 댓글 대댓글(parent_id) 기능 구현

> 작성일: 2026-04-23
> 대상: 다음 AI(또는 codex.cli 등)
> 프로젝트: SpringGreen8 (Spring MVC 4.3.14 + MyBatis 3.5 + MySQL + Tomcat 9, port 9090)
> 선행 작업 완료: NotificationService 도입, 공감/신고 알림 트리거, EmailService setFrom, 이메일 코드 5분 만료

---

## 목표

리뷰(Review)에 달린 댓글(Comment)에 **대댓글(reply)** 기능 추가.
즉, 댓글끼리 parent-child 관계를 만들어 2-depth 구조로 렌더링.
(3-depth 이상은 지원 안 해도 됨 — 대댓글에 또 대댓글이 달려도 parent_id는 최상위 댓글을 가리키도록 하는 "flat 2-depth" 구조 권장.)

---

## ⚠️ 건드리지 말 것 (사용자 결정 사항)

다음 3가지는 **절대 재권고/변경 금지** (`feedback_springgreen8_security_stance.md` 참조):

1. 비밀번호 해싱 SHA-256 유지 (BCrypt로 교체 ❌)
2. `app.properties`는 `.gitignore`로만 관리 (환경변수/Vault ❌)
3. `web.xml` 쿠키 `<secure>false</secure>` 유지 (로컬 HTTP 개발환경)

위 항목을 다시 건드리거나 지적하지 말 것. 이번 작업은 **순수 기능 구현**만.

---

## 현재 상태 (작업 전)

### DB 스키마
파일: `src/main/resources/sql/create_missing_tables.sql` (L55-65)

```sql
CREATE TABLE IF NOT EXISTS comment (
    comment_no INT AUTO_INCREMENT PRIMARY KEY,
    review_no  INT          NOT NULL,
    user_no    INT          DEFAULT NULL,   -- NULL = 탈퇴한 사용자
    content    VARCHAR(500) NOT NULL,
    reg_date   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_comment_review_no (review_no),
    CONSTRAINT fk_comment_review FOREIGN KEY (review_no) REFERENCES review(review_no)  ON DELETE CASCADE,
    CONSTRAINT fk_comment_user   FOREIGN KEY (user_no)   REFERENCES users(user_no)     ON DELETE SET NULL
);
```

**parent_id 컬럼이 없음.** 추가 필요.

### 관련 파일 위치
- VO: `src/main/java/com/spring/springGreen8/vo/CommentVO.java`
- DAO: `src/main/java/com/spring/springGreen8/dao/CommentDAO.java`
- Mapper XML: `src/main/resources/mappers/CommentMapper.xml`
- Service 인터페이스: `src/main/java/com/spring/springGreen8/service/CommentService.java`
- Service 구현: `src/main/java/com/spring/springGreen8/service/CommentServiceImpl.java`
- Controller: `src/main/java/com/spring/springGreen8/controller/CommentController.java`
- JSP/JS: `src/main/webapp/WEB-INF/views/movie/detail.jsp` (L1353~L1459 근방이 댓글 UI + JS)

### 알림 시스템 (참고)
`NotificationService`가 이미 있음. 필요하면 대댓글 작성 시에도 부모 댓글 작성자에게 알림 추가 고려.
- `createCommentNotification(CommentVO, senderUserId)` — 현재는 리뷰 작성자에게만 알림.
- 대댓글의 경우 **부모 댓글 작성자**에게 알림이 가야 함. 새 메서드 추가 권장: `createReplyNotification(CommentVO reply, CommentVO parent, String senderUserId)`.

---

## 구현 체크리스트 (단계별)

### 1. DB 마이그레이션 SQL 파일 추가

**신규 파일**: `src/main/resources/sql/add_comment_parent_id.sql`

```sql
-- 댓글 대댓글 기능을 위한 parent_id 컬럼 추가
-- parent_id NULL = 최상위(top-level) 댓글
-- parent_id NOT NULL = 대댓글(다른 댓글에 대한 답글), 값은 최상위 댓글의 comment_no

ALTER TABLE comment
    ADD COLUMN parent_id INT DEFAULT NULL AFTER review_no,
    ADD INDEX idx_comment_parent (parent_id),
    ADD CONSTRAINT fk_comment_parent
        FOREIGN KEY (parent_id) REFERENCES comment(comment_no) ON DELETE CASCADE;
```

그리고 `create_missing_tables.sql`의 comment 테이블 정의도 동일하게 갱신(새로 생성되는 환경용).

**중요**: `ON DELETE CASCADE` → 부모 댓글이 삭제되면 대댓글도 함께 삭제. 의도적인 선택이며 사용자 확인 필요. (다른 정책: `ON DELETE SET NULL`로 하여 부모가 삭제돼도 대댓글은 남기되 "삭제된 댓글에 대한 답글"로 표시하는 방법도 있음.)

### 2. `CommentVO` 수정

`parentId` 필드 추가. JOIN용 `parentUserName` 등은 실제 UI 요구에 따라 결정.

```java
@Data
public class CommentVO {
    private int commentNo;
    private int reviewNo;
    private Integer parentId;      // null = 최상위 댓글, 값 있음 = 대댓글
    private int userNo;
    private String content;
    private Date regDate;

    // JOIN용
    private String userName;
    private String userImg;

    // 부모 댓글 작성자명 표시용 (선택 — "@parentUserName 형태의 인용 표시")
    private String parentUserName;
}
```

`Integer`로 한 이유: `int`면 기본값 0이라 `parent_id IS NULL` 판별이 불가능. DB에서 `null` 받으려면 래퍼타입 필요.

### 3. `CommentMapper.xml` 수정

#### insertComment
```xml
<insert id="insertComment" parameterType="CommentVO">
    INSERT INTO comment (review_no, parent_id, user_no, content)
    VALUES (#{reviewNo}, #{parentId}, #{userNo}, #{content})
</insert>
```

#### selectCommentsByReviewNo
정렬 전략 권장: 최상위 댓글은 `reg_date ASC`, 각 최상위 댓글 아래 대댓글도 `reg_date ASC` 순.
SQL 한 방에 정렬하려면 "그룹키"를 만들어서 정렬. MySQL 5.7 이상이면 다음 패턴:

```xml
<select id="selectCommentsByReviewNo" parameterType="int" resultType="CommentVO">
    SELECT
        c.comment_no AS commentNo,
        c.review_no  AS reviewNo,
        c.parent_id  AS parentId,
        c.user_no    AS userNo,
        c.content    AS content,
        c.reg_date   AS regDate,
        COALESCE(u.user_name, '탈퇴한 사용자') AS userName,
        COALESCE(u.user_img, 'default.png')  AS userImg,
        pu.user_name AS parentUserName
    FROM comment c
    LEFT JOIN users u  ON c.user_no = u.user_no
    LEFT JOIN comment pc ON c.parent_id = pc.comment_no
    LEFT JOIN users   pu ON pc.user_no  = pu.user_no
    WHERE c.review_no = #{reviewNo}
    ORDER BY
        COALESCE(c.parent_id, c.comment_no) ASC,  -- 최상위 그룹키
        c.parent_id IS NOT NULL ASC,              -- 최상위(=NULL)가 먼저, 대댓글 나중
        c.reg_date ASC
</select>
```

또는 더 단순하게: 서버(Service 레이어)에서 최상위 리스트와 대댓글 리스트를 따로 조회해서 Controller에서 트리 형태로 병합. 둘 중 원하는 쪽 선택.

#### selectCommentByNo
`parent_id` 컬럼도 함께 select.

### 4. `CommentDAO.java` — 시그니처 변경 없음

기존 메서드 그대로. 필요하면 `selectReplyCount(int parentId)` 정도 추가.

### 5. `CommentService` / `CommentServiceImpl` 수정

- `writeComment(CommentVO, senderUserId)`의 로직 중 **parentId 검증** 추가:
  - parentId가 null이 아니면 → 해당 부모 댓글이 존재하고, 같은 reviewNo에 속해야 함.
  - 다른 리뷰의 댓글에 parent_id를 거는 공격 방어.
  - parentId가 가리키는 댓글이 자기 자신이면 안 됨(대댓글 INSERT 전이므로 자기 자신 불가이지만 방어적으로).
  - **"대댓글에 대한 대댓글"**은 flat 정책이면 grandparent의 id로 정규화:
    ```java
    if (parent.getParentId() != null) {
        vo.setParentId(parent.getParentId());  // 최상위로 정규화
    }
    ```
- 알림 분기:
  - 최상위 댓글 → 기존처럼 리뷰 작성자에게 알림.
  - 대댓글 → **부모 댓글 작성자**에게 알림 (+ 원한다면 리뷰 작성자에게도 알릴지 정책 결정).
  - 자기 자신이 부모면 알림 생략.

검증 후 기본 흐름:
```java
public int writeComment(CommentVO vo, String senderUserId) {
    if (vo.getParentId() != null) {
        CommentVO parent = commentDAO.selectCommentByNo(vo.getParentId());
        if (parent == null || parent.getReviewNo() != vo.getReviewNo()) {
            return 0; // invalid parent
        }
        // 2-depth flat 정책: 대댓글의 parent는 항상 최상위 댓글
        if (parent.getParentId() != null) {
            vo.setParentId(parent.getParentId());
        }
    }

    int result = commentDAO.insertComment(vo);
    if (result <= 0) return result;

    if (vo.getParentId() == null) {
        notificationService.createCommentNotification(vo, senderUserId);
    } else {
        notificationService.createReplyNotification(vo, senderUserId); // 신규 메서드
    }
    return result;
}
```

### 6. `NotificationService` — 신규 메서드 추가 (선택)

`createReplyNotification(CommentVO reply, String senderUserId)`:
- reply.getParentId()로 부모 댓글 조회
- 부모 작성자가 자기 자신이면 skip
- 부모 작성자의 user_id를 receiverMid로 하여 COMMENT 타입 알림(또는 새 타입 `REPLY`) 삽입
- 메시지 예: `"{senderUserId}님이 회원님의 댓글에 답글을 남겼습니다."`
- `refId`는 댓글이 달린 리뷰가 속한 영화의 tmdbId (기존 패턴과 동일)
- best-effort 처리 (comment 트랜잭션 롤백시키지 않음) — `REQUIRES_NEW` + try/catch 패턴

### 7. `CommentController.java` 수정

`/comment/write`에서 `parentId` 파라미터 받기. `CommentVO vo`에 자동 바인딩되므로 코드 수정 필요 없을 수도 있지만, 명시적 검증(예: parentId <= 0이면 null로 처리) 권장.

```java
@RequestMapping(value = "/write", method = RequestMethod.POST)
@ResponseBody
public String write(CommentVO vo, HttpSession session) {
    // ... (기존)
    // 0 또는 음수로 들어온 parentId는 null로 강제
    if (vo.getParentId() != null && vo.getParentId() <= 0) {
        vo.setParentId(null);
    }
    // ... (기존)
}
```

### 8. JSP/JS 수정 — `src/main/webapp/WEB-INF/views/movie/detail.jsp`

L1367~1390의 `loadComments(reviewNo)` 함수와 L1393~1412의 `writeComment(reviewNo)` 함수가 핵심.

**필요 변경**:
1. `loadComments`: 서버에서 받은 `list`를 `parentId`로 트리 그룹핑 후, 최상위 댓글 아래 대댓글을 들여쓰기(indent) 하여 렌더.
2. 각 댓글에 "답글" 링크 추가 → 클릭 시 인라인 입력창 열림.
3. `writeReply(parentCommentNo, reviewNo)` 함수 신규 추가 — `/comment/write`에 `parentId` 포함해서 POST.
4. CSS: `.comment-reply { margin-left: 24px; border-left: 2px solid #eee; padding-left: 12px; }` 정도.

예시 트리 렌더 로직 (jQuery + vanilla JS):

```javascript
function loadComments(reviewNo) {
    $.ajax({
        url: ctp + '/comment/list', type: 'GET',
        data: { reviewNo: reviewNo },
        success: function(list) {
            // 1. 최상위 / 대댓글 분리
            var tops = list.filter(function(c) { return c.parentId == null; });
            var repliesByParent = {};
            list.forEach(function(c) {
                if (c.parentId != null) {
                    (repliesByParent[c.parentId] = repliesByParent[c.parentId] || []).push(c);
                }
            });

            var html = '';
            tops.forEach(function(c) {
                html += renderCommentItem(c, false, reviewNo);
                (repliesByParent[c.commentNo] || []).forEach(function(r) {
                    html += renderCommentItem(r, true, reviewNo);
                });
                // 답글 입력창 placeholder (닫힌 상태)
                html += '<div id="replyBox-' + c.commentNo + '" style="display:none;"> ... </div>';
            });
            $('#commentList-' + reviewNo).html(html);
        }
    });
}

function renderCommentItem(c, isReply, reviewNo) {
    var klass = 'comment-item' + (isReply ? ' comment-reply' : '');
    var html = '<div class="' + klass + '" id="comment-' + c.commentNo + '">';
    html += '<div class="comment-main">';
    if (isReply && c.parentUserName) {
        html += '<span class="reply-mark">↳ @' + escapeHtml(c.parentUserName) + '</span> ';
    }
    html += '<span class="comment-author">' + escapeHtml(c.userName) + '</span>';
    html += '<span class="comment-text" id="commentText-' + c.commentNo + '">' + escapeHtml(c.content) + '</span>';
    html += '</div><div class="d-flex gap-2">';
    if (loginUserNo != 0 && !isReply) {
        html += '<span class="comment-link" onclick="toggleReplyBox(' + c.commentNo + ')">답글</span>';
    }
    if (loginUserNo != 0 && c.userNo == loginUserNo) {
        html += '<span class="comment-link" onclick="editComment(' + c.commentNo + ')">수정</span>';
    }
    if (loginUserNo != 0 && (c.userNo == loginUserNo || isAdmin)) {
        html += '<span class="comment-link" onclick="deleteComment(' + c.commentNo + ', ' + reviewNo + ')">삭제</span>';
    }
    html += '</div></div>';
    return html;
}

function writeReply(parentCommentNo, reviewNo) {
    var content = $('#replyInput-' + parentCommentNo).val();
    if (!content.trim()) return;
    $.ajax({
        url: ctp + '/comment/write', type: 'POST',
        data: { reviewNo: reviewNo, parentId: parentCommentNo, content: content },
        success: function(res) {
            if (res == 'ok') {
                $('#replyInput-' + parentCommentNo).val('');
                $('#replyBox-' + parentCommentNo).hide();
                loadComments(reviewNo);
            }
        }
    });
}
```

답글 박스 토글 함수(`toggleReplyBox`)와 마크업은 기존 댓글 작성 input-group을 복제해서 쓰면 됨.

### 9. XssFilter / InputValidator 영향

현재 `XssFilter`는 블랙리스트 기반으로 파라미터를 검사. `parentId`는 숫자만 허용되는 필드이므로 별도 작업 불필요. 단, `Integer.parseInt` 실패시 예외 처리 안전망 확인.

### 10. 테스트 시나리오

1. 최상위 댓글 작성 → 기존처럼 동작, 리뷰 작성자에게 알림
2. 대댓글 작성 → 부모 댓글 아래 들여쓰기 표시, 부모 댓글 작성자에게 알림
3. 자기 댓글에 자기 대댓글 → 알림 생략, 대댓글은 정상 생성
4. "대댓글에 대한 대댓글" 시도 → parent_id가 최상위로 정규화되어 flat 2-depth 유지
5. 다른 리뷰의 commentNo를 parentId로 위조 → 서버에서 거절(fail)
6. parentId=0 또는 음수 → null로 강제되어 최상위 댓글로 저장
7. 최상위 댓글 삭제 → CASCADE로 대댓글까지 삭제되는지 확인
8. 관리자가 대댓글 삭제 → 기존 권한 로직 그대로 동작
9. 탈퇴한 사용자의 대댓글 → `userName = '탈퇴한 사용자'` 표시 (기존 COALESCE 패턴)

---

## 우선순위 / 의존관계

1. SQL 마이그레이션(5분) → 2. VO + Mapper + DAO(15분) → 3. Service 로직 + 알림(20분) → 4. Controller(5분) → 5. JSP/JS(30~40분, UI 비용이 가장 큼) → 6. 테스트

SQL → VO → Mapper 순서만 지키면 됨. Service와 JSP는 병렬로도 가능.

---

## 참고 — 이미 완료된 관련 작업

- **NotificationService 레이어** 도입: `service/NotificationService.java`, `service/NotificationServiceImpl.java`
  - 댓글/공감/신고 알림 중앙화
  - `REQUIRES_NEW` + try/catch로 best-effort 패턴 확립 → 대댓글 알림도 같은 패턴 사용 권장
- **공감 알림**: `ReviewServiceImpl.toggleLike`에서 최초 좋아요 시만 알림
- **신고 결과 알림**: `AdminServiceImpl.updateReportStatus`에서 신고자에게 결과 통지

---

## 작성자 메모

- 이 작업은 DB 스키마가 바뀌므로 **로컬에서 SQL 실행 후** 재기동 필요. 사용자에게 "ALTER TABLE을 직접 실행해 주세요" 안내 필수.
- JSP/JS의 트리 렌더 로직이 가장 손이 많이 감. 복잡하면 `lodash.groupBy` 같은 외부 라이브러리 없이 순수 JS로 구현 권장(기존 코드가 외부 의존 없음).
- 사용자는 **한국어로 안내** 선호. 코드 주석도 한국어로 작성되어 있음 (기존 스타일 따르기).
- 플래그/프로그레스 표시 UI는 기존 `Swal` / Bootstrap Toast 패턴 재사용.

끝.
