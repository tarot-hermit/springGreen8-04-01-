# SpringGreen8 기능 구현도 및 보안 점검 보고서

- 점검일: 2026-04-23
- 점검자: Claude (Cowork)
- 점검 대상 커밋: 워크스페이스 현재 상태 (`D:\springgreen\springframework\springGreen8`)
- 점검 우선순위: 기능 구현 완성도 > 보안
- 기반 자료: `src/main/java`, `src/main/resources`, `src/main/webapp/WEB-INF` 전체 파일 정적 분석

---

## 1. 총평

| 구분 | 점수 | 한줄평 |
| --- | --- | --- |
| 전체 기능 완성도 | **88 / 100** | 핵심 플로우(탐색·회원·커뮤니티·관리자)가 모두 끝단까지 연결되어 실제 구동 가능. 일부 기능이 컨트롤러만 있거나 연동이 일부 누락됨. |
| 탐색 모듈(영화/드라마/애니) | **98 / 100** | URL→Service→JSP 연결이 가장 탄탄함. TMDB/YouTube 폴백·캐싱까지 완비. |
| 회원·인증 모듈 | **88 / 100** | 회원가입·로그인·카카오·찾기·탈퇴까지 끝단 동작 가능. 이메일 인증 유효시간·setFrom 등 디테일 공백 존재. |
| 커뮤니티 모듈 | **80 / 100** | 리뷰·댓글·컬렉션·시청기록·위시리스트·신고는 DB까지 연결. 알림(Notification) 서비스 계층과 트리거가 비어 있음. |
| 관리자 모듈 | **85 / 100** | 대시보드·회원·리뷰·신고 관리 기본 기능 완비. 감사로그·벌크처리·서버사이드 페이징 부재. |
| 보안 | **55 / 100** | MyBatis 파라미터화는 잘 되어 있으나 **시크릿 평문 노출 / CSRF 미구현 / 쿠키 Secure=false** 등 치명적 이슈 다수. |

---

## 2. 모듈별 기능 구현도

### 2.1 탐색 모듈 (MovieController + TmdbServiceImpl)

Controller 엔드포인트 → Service 메서드 → JSP 까지 전부 연결된 상태.

| URL | Service 호출 | 뷰 | 상태 |
| --- | --- | --- | --- |
| `/movie/list` | getPopularMovies / getNowPlaying / getTopRated | movie/list.jsp | 완성 |
| `/movie/tv` | getPopular/OnTheAir/TopRatedTv | movie/tvList.jsp | 완성 |
| `/movie/animation` | getAnimationMovies / TvShows | movie/animationList.jsp | 완성 |
| `/movie/all` | 4종 병합 | movie/allList.jsp | 완성 |
| `/movie/detail/{id}` | getMovieDetail + cast/crew/videos/keywords/providers | movie/detail.jsp | 완성 |
| `/movie/tv/{id}` | getTvDetail + 시즌/에피소드 비디오 | movie/tvDetail.jsp | 완성 |
| `/movie/search`, `/movie/genre`, `/movie/person/{id}` | 각 Service 메서드 | 각 JSP | 완성 |
| `/movie/upcoming`, `/movie/trending` | getUpcomingMovies / getTrendingMovies | 각 JSP | 완성 |
| `/movie/api/*` (JSON) | 3종 | JSON 응답 | 완성 |

**강점**
- TmdbServiceImpl(2015줄) 안에 TMDB 1차 호출 → YouTube 폴백 → DB 캐시 적재 순으로 **3단 파이프라인**이 완비되어 있음.
- `MediaVideoCache` 는 insert/select/delete 경로가 모두 Mapper에 존재하며 Service에서 사용됨.
- `SearchHistory` 는 저장·조회·개별삭제·전체삭제 전부 엔드투엔드 연결.

**주의**
- `TmdbServiceImpl`의 YouTube 쿼터 차단이 JVM 프로세스 메모리 플래그로만 관리되어 **서버 재시작 시 초기화**, 다중 인스턴스 공유 불가.
- `Controller:128~141` - 비로그인 시 `myReview` / `myWatch` 속성이 Model에 세팅되지 않음. `movie/detail.jsp`에서 null-safe 참조가 되어 있는지 확인 필요.
- API 키 `app.properties`에 평문 (보안 섹션에서 별도 다룸).

### 2.2 회원·인증 모듈

**완결된 플로우**
- 회원가입: 입력검증(InputValidator) → 중복확인(AJAX) → 이메일 인증(세션 저장) → SHA-256 해싱 후 insertUser → 로그인 유도.
- 로그인: `LoginAttemptService`가 5회 실패 시 10분 잠금. `UserSessionRegistry`가 동일 계정 다중 세션을 무효화.
- 카카오 로그인: 토큰 교환 → 프로필 조회 → 기존 계정 연결(`kakaoLinkForm/Proc`) 또는 `kakao_{id}` 로 신규 가입(UUID 해시 비번).
- 아이디/비번 찾기: 이메일 인증 코드 → 마스킹된 ID 반환 / 비번 재설정.
- 마이페이지/정보수정/탈퇴: 프로필 이미지 업로드(UUID 파일명), 소프트 삭제(`is_deleted=1`) + `withdrawn_user_id` 보존으로 재가입 차단.

**미흡/누락 항목**

| 항목 | 위치 | 설명 |
| --- | --- | --- |
| 이메일 인증 시간 제한 | `EmailService.java:49` (문구), `UserController.java:435-452` (검증) | 메일 본문에 "5분 유효" 문구만 있고 서버 측 만료 체크가 없음. 세션 타임아웃(30분) 동안 유효. |
| `helper.setFrom()` 누락 | `EmailService.java:32` 부근 | 발신자 주소 명시가 없음. SMTP 서버가 username을 자동 설정해주긴 하지만 Gmail은 반송·스팸 분류에 취약. |
| **비밀번호 해싱이 SHA-256** | `UserServiceImpl`, `UserController:changePw` | `pom.xml`/`servlet-context.xml`에 `BCryptPasswordEncoder` 빈이 있음에도 실제 해싱은 `DigestUtils.sha256Hex()` 사용. BCrypt 빈이 주입되어 쓰이는 지점이 없음. **보안 H급 이슈** (아래 보안 섹션 참조). |
| `UserVO` 탈퇴 필드 미노출 | `UserVO.java` | `is_deleted`, `deleted_at`이 컬럼만 있고 VO에 없음. 탈퇴 상태를 코드에서 판단하기 어려움. |
| findPw 응답 포맷 | `UserController.java:647-665` | `"ok"` / `"fail"` 순수 문자열만 반환. JSP에서 정확히 일치 비교를 하는지 확인 필요. |
| 이메일 인증용 임시 값 저장소 | `UserController` 여러 곳 | 세션에 `emailCode` 하나만 저장. 재전송 시간 간격 제한 없음 → 메일 폭탄 가능. |

### 2.3 커뮤니티 모듈 (Review / Comment / Collection / Watched / Watchlist / Report / Notification)

| 기능 | Controller | Service | DAO/Mapper | JSP | 상태 |
| --- | --- | --- | --- | --- | --- |
| 리뷰 CRUD + 좋아요 | ✓ | ✓ | ✓ | ✓ | 완성 |
| 별점 분포·정렬 | ✓ | ✓ | ✓ | ✓ | 완성 |
| 댓글 CRUD | ✓ | ✓ | ✓ | ✓ | 완성 (평탄 구조) |
| **대댓글(parent_id)** | - | - | - | - | **미구현** (CommentVO에 parent 필드 없음) |
| 컬렉션 CRUD + 공개 | ✓ | ✓ | ✓ | ✓ | 완성 |
| 컬렉션 아이템 toggle | ✓ | ✓ | ✓ | ✓ | 완성 |
| 시청기록 toggle | ✓ | ✓ | ✓ | ✓ | 완성 (라우팅은 `/movie/watched/toggle`로 MovieController에 있음) |
| 위시리스트 toggle | ✓ | ✓ | ✓ | ✓ | 완성 |
| 신고 접수 | ✓ (`/report/insert`만) | ✓ (dup 처리) | ✓ | - | 완성 |
| **신고 관리(관리자)** | - (ReportController에 없음) | - | ✓ | ✓ (admin/reportList.jsp) | **컨트롤러 누락** - 조회·상태변경은 `AdminController`가 수행 |
| 댓글 알림 생성 | ✓ | ✓ | ✓ | - | 완성 |
| **리뷰 좋아요 알림** | - | - | ✓ | - | **트리거 미구현** |
| **신고 처리 알림** | - | - | ✓ | - | **트리거 미구현** |
| **NotificationService 계층** | - | - | - | - | **부재** — `NotificationController`가 `NotificationDAO`를 직접 호출 |

**핵심 지적**
- `NotificationService.java`는 존재하지 않음(검증됨). `NotificationController.java:80줄`이 DAO를 직접 호출함 → 알림 생성 로직을 중앙화할 곳이 없어서 새 이벤트(예: 좋아요 알림)를 추가하려면 Controller/Service들을 여기저기 수정해야 함.
- `ReportController.java`는 신고 접수 한 개 엔드포인트만 존재. 관리자 목록·상태변경은 `AdminController` 쪽에 있음 (책임이 분산됨). 설계 일관성을 위해 신고 관리 엔드포인트를 `AdminReportController` 또는 별도로 분리 권장.
- `CommentVO`와 `CommentMapper.xml`에 `parent` 관련 컬럼·필드가 없음(검증됨). 대댓글 지원하려면 스키마 + VO + Mapper + JSP 모두 수정 필요.

### 2.4 관리자 모듈

- 대시보드: 회원·리뷰·댓글·찜 수 + 미처리 신고 + 인기 검색어 TOP10 (`dashboard.jsp` 완성).
- 회원관리: 목록·검색·권한 변경(ADMIN/USER)·강제 탈퇴. `AdminController:66-94`.
- 리뷰관리: 목록·검색·삭제·블라인드 표시. `AdminController:110-123`.
- 신고관리: 상태 변경 시 `AdminServiceImpl:21-34`에서 **대상 리뷰를 블라인드 메시지로 자동 변환**까지 수행.

**개선 포인트**
- 감사 로그(Audit Log) 없음. 관리자 행위(권한 변경, 강제 삭제)를 추적할 수 없음.
- `reportList.jsp` 의 검색·필터가 클라이언트 사이드. 데이터 누적 시 체감 느려짐.
- 벌크 처리(다건 선택 → 일괄 처리) 미지원.
- 관리자 자기 자신의 권한을 강등할 때 안전장치(최소 관리자 1인 유지) 없음.

### 2.5 외부 API 연동

- **TMDB**: RestTemplate 경유, `TmdbServiceImpl.resolveApiKey()` (55-59줄) 가 `@Value` 읽어 사용. 정상 연결.
- **YouTube**: TMDB 영상이 비었을 때 폴백. 쿼터 초과 시 프로세스 내 차단. 정상 동작하지만 다중 인스턴스 공유 불가.
- **Kakao OAuth**: `KakaoLoginServiceImpl.java` 에서 `@Value` 로 clientId/secret/redirect_uri 주입. `kakao.redirect.uri`가 카카오 개발자 콘솔 등록값과 **완전히 일치**해야 하므로 배포 시 꼭 확인.
- **Gmail SMTP**: `javax.mail` + Spring JavaMailSender. `setFrom` 누락(앞서 언급) 외에는 정상.

---

## 3. 보안 이슈 (부차 점검이지만 치명적 항목 존재)

### 3.1 HIGH (즉시 조치)

1. **시크릿·API 키 평문 저장**
   - 위치: `src/main/resources/app.properties` 1~14줄
   - 노출된 값: DB 비밀번호 `1234`, Gmail 앱 비밀번호, TMDB 키, YouTube 키, Kakao clientId + **client_secret**.
   - 조치:
     - 현재 값 **전부 회전(재발급)**: Gmail 앱 비밀번호 재발급, TMDB/YouTube 키 재생성, Kakao client_secret 재생성, DB 비밀번호 변경.
     - `app.properties`를 `.gitignore`에 추가하고, 환경변수 또는 별도 `app-local.properties`(커밋 제외)로 분리.
     - Git 히스토리에 이미 들어간 경우 `git filter-repo`로 과거 커밋에서도 제거 필요.

2. **비밀번호 해싱 알고리즘이 SHA-256 (BCrypt 미사용)**
   - 현상: `servlet-context.xml`에 `BCryptPasswordEncoder` 빈이 정의되어 있고 pom.xml에도 `spring-security-core` 의존성이 들어가 있음에도, 실제 비밀번호 저장·검증은 `DigestUtils.sha256Hex(pw)` 단일 해시.
   - 위험: Salt 없는 SHA-256은 레인보우 테이블·GPU 공격에 매우 취약.
   - 조치: `UserServiceImpl`의 `insertUser`, `UserController`의 로그인/비번변경/비번찾기/카카오조인 전부를 `BCryptPasswordEncoder.encode/matches`로 교체. 기존 사용자 마이그레이션은 "로그인 성공 시 재해싱" 전략 권장.

3. **CSRF 보호 전무**
   - `web.xml`, `servlet-context.xml`, JSP 어디에도 CSRF 토큰 발급·검증 없음. Spring Security는 BCrypt 전용으로만 쓰이고 `http-security` 설정은 없음.
   - 위험: 로그인 상태에서 악성 페이지 방문만으로 회원 탈퇴/리뷰 삭제/관리자 삭제가 가능.
   - 조치: Spring Security `<http>` 에 CSRF 필터 활성화, 또는 커스텀 CSRF 토큰을 세션에 발급하고 모든 POST에서 hidden input + 서버 검증.

4. **쿠키 Secure=false**
   - `web.xml` 69줄 `<secure>false</secure>`.
   - HTTP 전송 시 세션 쿠키 평문 노출 → 세션 탈취.
   - 조치: 운영 환경에서 `true`, 개발에서만 `false` (프로파일 분기) + HTTPS 강제.

5. **세션 고정(Session Fixation) 방어 미흡**
   - `startLoginSession` 에서 `session.invalidate()` 또는 `changeSessionId()` 호출이 없음. 로그인 전 공격자가 심어둔 세션 ID가 그대로 상승됨.
   - 조치: 로그인 성공 시 `request.changeSessionId()` 호출, 또는 기존 세션 무효화 후 새 세션 생성.

### 3.2 MEDIUM

1. **XssFilter가 블랙리스트 기반**
   - `XssRequestWrapper.java`는 `<script|style|iframe|object|embed|link|meta|base>` 차단. `<svg onload>`, `<img onerror>`, `javascript:` URI 등 미차단.
   - 조치: OWASP Java HTML Sanitizer 또는 Jsoup `Safelist.basic()` 기반 화이트리스트로 교체.

2. **파일 업로드 검증**
   - `UserController:731~738` 프로필 이미지 업로드는 UUID 파일명 + 확장자 문자열 비교.
   - 이미지 파일 매직 바이트 검사는 부분적으로만 존재. SVG(XML) 업로드 시 XSS 가능.
   - 조치: MIME 화이트리스트(jpg/png/webp만), 매직 바이트 확인, SVG 차단.

3. **세션 타임아웃 30분**
   - 공용 PC 환경에서 길다. 관리자 페이지는 특히 짧게.
   - 조치: 일반 15분, 관리자 5분. `AdminInterceptor`에서 마지막 활동 시간 검증 추가 권장.

4. **에러 페이지 정보 노출 여부**
   - `/WEB-INF/views/error/500.jsp` 내용에 따라 스택트레이스 노출 가능. (내용 확인 권장)

5. **`InputValidator.hasSqlInjection`이 실제로 호출되는 곳이 거의 없음**
   - MyBatis #{} 파라미터화가 있어서 기본 방어는 되지만, 이중 방어 목적으로 설계한 함수가 사용되지 않는 상태.

### 3.3 LOW

- `maxUploadSize = 10MB` 는 프로필·컬렉션 썸네일에 과함. 2MB 권장.
- 로그에 비밀번호/이메일 코드 평문이 찍히지 않도록 로그 레벨·마스킹 정책 명시 필요.
- 리뷰 삭제 시 `review_like` 외래키 ON DELETE CASCADE 구성 확인 필요.

### 3.4 SQL Injection 전수 조사 결과

모든 `mappers/*.xml` 전수 검토 결과 **`${}` 직접 치환 사용 없음**. 파라미터는 전부 `#{}` 사용. ORDER BY 동적 정렬도 정적 컬럼명 기반.
→ **SQL Injection은 현재 코드 기준 해당 없음**.

---

## 4. 우선순위별 조치 리스트

### 이번 주 (P0)
1. `app.properties` 시크릿 전부 회전 + 파일 버전관리 제외.
2. 비밀번호 해싱을 BCrypt로 교체 (신규 가입부터 즉시, 기존은 로그인 시 마이그레이션).
3. CSRF 토큰 도입 (최소한 관리자 페이지부터).
4. 쿠키 Secure=true + HTTPS.
5. 이메일 인증 코드 서버 측 만료 시간(5분) 검증 추가.

### 2주 내 (P1)
6. `NotificationService` 도입 + 리뷰 좋아요/신고 처리 알림 트리거 연결.
7. `ReportController` 에 관리자용 엔드포인트(`/report/list`, `/report/updateStatus`) 이관 또는 `AdminReportController`로 분리.
8. 세션 고정 방어(`changeSessionId`) 적용.
9. XssFilter 화이트리스트 라이브러리로 교체.
10. `EmailService.helper.setFrom()` 명시.

### 한달 내 (P2)
11. 관리자 액션 감사 로그 테이블 및 AOP 기반 기록.
12. 신고·리뷰 관리 화면 서버사이드 페이징/필터.
13. 댓글 대댓글(parent_id) 지원.
14. YouTube 쿼터 차단 상태를 DB/Redis로 공유.
15. 파일 업로드 매직 바이트 검증 강화.

---

## 5. 빠른 확인용 체크리스트

- [ ] `app.properties`의 5개 시크릿 전부 재발급·환경변수화
- [ ] `UserServiceImpl` / `UserController` 비번 관련 모든 경로 BCrypt 전환
- [ ] Spring Security CSRF 필터 활성화 또는 커스텀 토큰 도입
- [ ] `web.xml` `<secure>true</secure>` (운영 프로파일)
- [ ] 이메일 인증 코드 만료 시간 서버 검증 (세션에 `emailCodeSentAt` 기록)
- [ ] `EmailService` `helper.setFrom()` 추가
- [ ] `NotificationService` 신설 + 좋아요/신고 이벤트 트리거
- [ ] `ReportController` vs `AdminController` 책임 재분배
- [ ] XssFilter → Jsoup/OWASP Sanitizer
- [ ] 관리자 감사 로그 도입

---

_본 문서는 소스 정적 분석 기반이며 실 배포 환경에서의 동작은 별도 검증이 필요합니다. 각 지적사항 옆에 가능한 한 파일·라인을 명시했으니 수정 PR 작성 시 그대로 참조하면 됩니다._
