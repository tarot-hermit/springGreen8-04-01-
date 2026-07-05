# springGreen8 기능 점검 리포트
> 점검일: 2026-05-04  
> 점검 범위: 전체 소스 (Controller, Service, DAO, Mapper XML, Filter, Interceptor)

---

## 설정 파일 점검 결과

| 항목 | 상태 |
|------|------|
| pom.xml 의존성 | ✅ 이상 없음 |
| web.xml 필터/서블릿 | ✅ 이상 없음 |
| root-context.xml (DB/MyBatis) | ✅ 이상 없음 |
| servlet-context.xml (MVC/인터셉터) | ⚠️ 인터셉터 매핑 누락 2건 |

**인터셉터 누락 URL (경미)**
- `/notification/open` — 컨트롤러 내부에서 null 체크하므로 보안 문제 없음
- `/collection/my` — 비로그인 시 빈 목록 반환 (의도된 동작으로 추정)

---

## DAO ↔ Mapper XML 일치 여부

✅ User/Review/Collection/Comment/Notification 전체 이상 없음

---

## 버그 목록

### 🔴 높음 — 즉시 수정 필요

---

#### BUG-01: `UserServiceImpl.withdrawUser()` — 트랜잭션 롤백 불가

**파일**: `service/UserServiceImpl.java`

**문제**: 회원 탈퇴 메서드에서 각 DAO 호출을 개별 `try-catch(Exception ignored)`로 감싸고 있어, 중간에 예외가 발생해도 묻혀버리고 `@Transactional` 롤백이 작동하지 않습니다. 예를 들어 watchlist 삭제는 성공했는데 collection 삭제에서 오류가 나면, 부분 삭제된 상태로 커밋됩니다.

```java
// 현재 (잘못된 코드)
try { watchedDAO.deleteWatchedByMid(mid); } catch (Exception ignored) {}
try { collectionDAO.deleteCollectionsByMid(mid); } catch (Exception ignored) {}

// 수정: try-catch 제거하고 예외가 전파되도록
watchedDAO.deleteWatchedByMid(mid);
collectionDAO.deleteCollectionsByMid(mid);
// @Transactional이 자동으로 롤백 처리
```

---

#### BUG-02: `NotificationServiceImpl.createCommentNotification()` — 알림 실패 시 댓글도 롤백

**파일**: `service/NotificationServiceImpl.java` (약 46줄)

**문제**: `createCommentNotification()`에 `Propagation.REQUIRES_NEW`가 없어서, 알림 삽입 실패 시 댓글까지 같이 롤백됩니다. `createLikeNotification()`과 `createReplyNotification()`은 `REQUIRES_NEW`로 올바르게 처리되어 있는데, 이것만 빠져 있습니다.

**비유**: 라면 끓이다가 마지막에 파 올리는 게 실패했다고 라면 전체를 버리는 것과 같습니다.

```java
// 수정
@Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
public void createCommentNotification(CommentVO vo, String senderUserId) { ... }
```

---

#### BUG-03: `WatchlistServiceImpl.toggleWatch()` — NullPointerException 위험

**파일**: `service/WatchlistServiceImpl.java` (약 37줄)

**문제**: TMDB에서 영화를 새로 INSERT한 직후 바로 재조회하는데, 이 재조회가 `null`을 반환하면 `movie.getMovieNo()`에서 NPE가 납니다. `ReviewServiceImpl`에는 null 체크가 있는데 여기는 없습니다.

```java
// 수정
movieDAO.insertMovie(tmdbMovie);
movie = movieDAO.selectMovieByTmdbId(vo.getMovieNo());
if (movie == null) return 0;  // ← 이 줄 추가
vo.setMovieNo(movie.getMovieNo());
```

---

#### BUG-04: `XssRequestWrapper.CachedServletInputStream` — Servlet 3.1 메서드 미구현

**파일**: `filter/XssRequestWrapper.java` (약 172줄)

**문제**: `ServletInputStream`의 추상 메서드인 `isFinished()`, `isReady()`, `setReadListener()`가 구현되지 않았습니다. Tomcat 9 환경에서 비동기 요청 처리 시 `AbstractMethodError`로 필터 체인이 중단될 수 있습니다.

```java
// 수정: 내부 클래스에 다음 메서드 추가
@Override public boolean isFinished() { return inputStream.available() == 0; }
@Override public boolean isReady() { return true; }
@Override public void setReadListener(ReadListener listener) {}
```

---

### 🟡 중간 — 가급적 수정 권장

---

#### BUG-05: `UserController` — 이메일 인증 코드 세션 키 공유

**파일**: `controller/UserController.java`

**문제**: 회원가입용 `/sendEmail`, 아이디 찾기 `/findId/sendCode`, 비밀번호 찾기 `/findPw/sendCode`가 `emailCode`와 `emailVerified`라는 **같은 세션 키**를 사용합니다. `/findPw/sendCode`로 코드를 발급받고 `/checkEmailCode`(가입용)를 호출하면 `emailVerified=true`가 세션에 기록되어 이메일 인증 없이 회원가입이 가능할 수 있습니다.

**수정**: 각 흐름별로 세션 키를 분리 (`joinEmailCode`, `findIdEmailCode`, `findPwEmailCode`)

---

#### BUG-06: `ReviewController.write()` — 신규 영화 중복 리뷰 가능

**파일**: `controller/ReviewController.java` (약 44줄)

**문제**: 영화가 DB에 없을 때는 중복 리뷰 체크를 건너뛰고 바로 삽입합니다. 동시에 두 번 요청하면 DB에 UNIQUE 제약이 없는 경우 중복 리뷰가 들어갈 수 있습니다.

---

#### BUG-07: `LoginSessionInterceptor` — 모든 요청마다 DB 조회

**파일**: `LoginSessionInterceptor.java`

**문제**: 인터셉터가 보호 URL에 진입할 때마다 DB에서 사용자 정보를 재조회합니다. 사용 빈도가 높은 엔드포인트에서 불필요한 DB 부하가 됩니다. 세션 갱신 주기를 두거나 변경이 있을 때만 재조회하는 방식으로 개선이 필요합니다.

---

#### BUG-08: `UserController.resolveClientIp()` — IP 위조로 로그인 잠금 우회 가능

**파일**: `controller/UserController.java` (약 793줄)

**문제**: `X-Forwarded-For` 헤더를 그대로 신뢰합니다. 공격자가 `X-Forwarded-For: 127.0.0.1`을 보내면 IP 기반 로그인 시도 제한을 우회할 수 있습니다. 리버스 프록시 환경이 아니라면 헤더를 신뢰하지 않고 `request.getRemoteAddr()`를 사용해야 합니다.

---

#### BUG-09: `MovieController.search()` — 검색 결과 수 오기록

**파일**: `controller/MovieController.java` (약 225줄)

**문제**: `resultCnt`에 전체 결과 수가 아닌 현재 페이지의 결과 수(최대 20)가 저장됩니다.

---

#### BUG-10: `XssRequestWrapper` — data: URI 변형 우회 가능

**파일**: `filter/XssRequestWrapper.java` (약 31줄)

**문제**: `data:text/html`만 차단하고, `data:image/svg+xml`, `data:application/javascript` 같은 변형은 차단하지 않습니다.

---

### 🟢 낮음 — 코드 품질 개선

---

#### BUG-11: `CommentServiceImpl.writeComment()` — Integer != 비교 주의

`parent.getReviewNo() != vo.getReviewNo()` 비교에서 `ReviewNo`가 `Integer` 래퍼 타입이면 128 초과 값에서 객체 참조 비교가 되어 항상 불일치를 반환합니다. `.equals()` 또는 `intValue()` 비교로 변경 권장.

---

#### BUG-12: `UserServiceImpl.joinKakaoUser()` — insertSocialUser keyProperty 누락

**파일**: `service/UserServiceImpl.java` (약 185줄) / `UserMapper.xml`

`insertSocialUser`에 `useGeneratedKeys="true" keyProperty="userNo"` 없으면 INSERT 후 생성된 PK가 VO에 채워지지 않아, 이후 `selectUserByNo(0)` → null → NPE 발생. (BUG-01과 동일 파일에서 발견된 별개 문제)

```xml
<!-- 수정 -->
<insert id="insertSocialUser" parameterType="UserVO" useGeneratedKeys="true" keyProperty="userNo">
```

---

#### BUG-13: `UserController.editProc()` — 프로필 이미지 삭제 경로 검증 미흡

파일 삭제 시 `loginUser.getUserImg()`에 경로 순회 문자가 포함될 경우를 대비해 `new File(path).getName()`으로 파일명만 추출 후 삭제 권장.

---

#### BUG-14: `AdminInterceptor` — DB 중복 재조회

`LoginSessionInterceptor`가 이미 세션을 갱신했다면 `AdminInterceptor`의 재조회는 중복입니다.

---

## 우선순위 수정 목록

| 우선순위 | 버그 | 파일 |
|---------|------|------|
| 1 | BUG-04: XssRequestWrapper Servlet 3.1 미구현 | filter/XssRequestWrapper.java |
| 2 | BUG-02: createCommentNotification REQUIRES_NEW 누락 | service/NotificationServiceImpl.java |
| 3 | BUG-03: toggleWatch NPE | service/WatchlistServiceImpl.java |
| 4 | BUG-12: insertSocialUser keyProperty 누락 (카카오 가입 불가) | resources/mappers/UserMapper.xml |
| 5 | BUG-01: withdrawUser exception swallow | service/UserServiceImpl.java |
| 6 | BUG-05: 이메일 인증 세션 키 공유 | controller/UserController.java |
| 7 | BUG-08: X-Forwarded-For 위조 | controller/UserController.java |
