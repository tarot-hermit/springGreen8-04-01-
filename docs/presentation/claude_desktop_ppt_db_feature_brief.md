# SpringGreen8 Claude Desktop PPT 전달 자료

## 목적
이 문서는 Claude Desktop에서 SpringGreen8 프로젝트 발표용 PPT를 만들 때 함께 보내기 위한 자료다.

발표 조건은 다음과 같다.

- 슬라이드 수 제한 없음
- 내부 DB 테이블 설명 포함
- 기능이 실제로 어떤 코드 구조로 구현되어 있는지 포함
- 단순 기능 소개가 아니라 `문제 정의 -> 구조 -> DB -> 기능 구현 -> 개선 사례 -> 결과` 흐름으로 구성
- 스타일은 `포토폴리오(FIND_KAPOOR).pdf`의 여백감, 섹션 분리, 캡처 중심 구성을 참고

## Claude Desktop에 첨부하면 좋은 파일

### 1. 반드시 첨부
- `C:/Users/green/Desktop/포토폴리오(FIND_KAPOOR).pdf`
- `docs/presentation/claude_desktop_ppt_db_feature_brief.md`
- `docs/presentation/claude_desktop_project_context.md`
- `docs/presentation/claude_desktop_ppt_master_brief.md`
- `src/main/webapp/WEB-INF/views/springGreen8.sql`

### 2. DB 구현 근거용 첨부
- `src/main/resources/mappers/UserMapper.xml`
- `src/main/resources/mappers/MovieMapper.xml`
- `src/main/resources/mappers/ReviewMapper.xml`
- `src/main/resources/mappers/CommentMapper.xml`
- `src/main/resources/mappers/WatchlistMapper.xml`
- `src/main/resources/mappers/WatchedMapper.xml`
- `src/main/resources/mappers/CollectionMapper.xml`
- `src/main/resources/mappers/ReportMapper.xml`
- `src/main/resources/mappers/NotificationMapper.xml`
- `src/main/resources/mappers/SearchHistoryMapper.xml`
- `src/main/resources/mappers/MediaVideoCacheMapper.xml`
- `src/main/resources/mappers/AdminMapper.xml`

### 3. 기능 구현 근거용 첨부
- `src/main/java/com/spring/springGreen8/HomeController.java`
- `src/main/java/com/spring/springGreen8/controller/MovieController.java`
- `src/main/java/com/spring/springGreen8/controller/UserController.java`
- `src/main/java/com/spring/springGreen8/controller/ReviewController.java`
- `src/main/java/com/spring/springGreen8/controller/CommentController.java`
- `src/main/java/com/spring/springGreen8/controller/CollectionController.java`
- `src/main/java/com/spring/springGreen8/controller/ReportController.java`
- `src/main/java/com/spring/springGreen8/controller/NotificationController.java`
- `src/main/java/com/spring/springGreen8/controller/AdminController.java`
- `src/main/java/com/spring/springGreen8/controller/GlobalViewOptionsAdvice.java`
- `src/main/java/com/spring/springGreen8/service/TmdbService.java`
- `src/main/java/com/spring/springGreen8/service/TmdbServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/UserServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/ReviewServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/WatchlistServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/WatchedServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/CollectionServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/AdminServiceImpl.java`
- `src/main/java/com/spring/springGreen8/service/EmailService.java`
- `src/main/java/com/spring/springGreen8/util/InputValidator.java`
- `src/main/java/com/spring/springGreen8/AdminInterceptor.java`
- `src/main/java/com/spring/springGreen8/filter/XssFilter.java`
- `src/main/java/com/spring/springGreen8/filter/XssRequestWrapper.java`
- `src/main/webapp/WEB-INF/spring/root-context.xml`
- `src/main/webapp/WEB-INF/spring/appServlet/servlet-context.xml`
- `src/main/webapp/WEB-INF/web.xml`

### 4. 화면 캡처 자료
PPT에 실제 화면을 넣으려면 아래 화면 캡처도 함께 보내는 것이 좋다.

- 홈 화면
- 영화 목록 화면
- 드라마 목록 화면
- 애니메이션 목록 화면
- 검색 화면
- 영화 상세 화면
- 드라마 상세 화면
- 리뷰/댓글 영역
- 마이페이지
- 컬렉션 목록/상세 화면
- 관리자 대시보드
- 관리자 회원 관리
- 관리자 리뷰 관리
- 관리자 신고 관리

## 프로젝트 한 줄 요약
SpringGreen8은 영화, 드라마, 애니메이션 콘텐츠를 탐색하고 검색하며, 상세 정보와 예고편, 키워드, OTT 제공처, 리뷰, 댓글, 찜, 봤어요, 컬렉션, 신고, 관리자 기능까지 연결한 Spring MVC 기반 콘텐츠 커뮤니티 웹 프로젝트다.

## 기술 스택
- Backend: Java 11, Spring MVC 4.3.14
- View: JSP, JSTL, Bootstrap, jQuery
- DB: MySQL
- Persistence: MyBatis
- External API: TMDB API, YouTube Data API fallback
- Mail: JavaMailSender, Gmail SMTP
- 보안/검증: 세션 기반 로그인, 관리자 인터셉터, XSS 필터, InputValidator

## 전체 아키텍처
발표에서는 아래 구조를 도식화하면 좋다.

```text
Browser
  -> DispatcherServlet
  -> Controller
  -> Service
  -> DAO Interface
  -> MyBatis Mapper XML
  -> MySQL

외부 콘텐츠 데이터:
Controller -> TmdbServiceImpl -> TMDB API / YouTube API

공통 데이터:
GlobalViewOptionsAdvice -> 인기 검색어 / 관리자 통계 / 국가 옵션

보안 흐름:
web.xml -> EncodingFilter -> XssFilter -> Controller
admin/** -> AdminInterceptor -> 관리자 권한 확인
```

## DB 테이블 설명 기준
현재 저장소의 `springGreen8.sql`에는 `users`, `media_video_cache` 두 테이블의 DDL만 들어 있다.

따라서 `springGreen8.sql` 파일만 기준으로 말하면 현재 생성 정의가 있는 테이블은 2개가 맞다.

다만 MyBatis Mapper와 VO에는 `movie`, `review`, `comment`처럼 추가 테이블을 조회/저장하는 SQL이 존재한다. 이 테이블들은 현재 `springGreen8.sql`에는 DDL이 없으므로, PPT에서는 "현재 SQL에 생성되어 있는 테이블"과 "코드가 참조하는 추가 필요 테이블"을 반드시 구분해서 설명해야 한다.

- `현재 springGreen8.sql 기준 생성 테이블`: users, media_video_cache
- `Mapper와 VO 기준으로 코드가 참조하는 추가 필요 테이블`: movie, review, review_like, comment, watchlist, watched, collection, collection_movie, report, notification, search_history
- 실제 DB 안에 추가 테이블이 이미 만들어져 있다면, 그 전체 DDL을 별도로 추출해서 Claude Desktop에 첨부해야 정확한 ERD를 만들 수 있다.
- 전체 DDL이 없다면, 발표에서는 추가 테이블을 "현재 SQL에 없는 Mapper 참조 테이블" 또는 "기능 구현상 필요한 테이블"로 표현하는 것이 안전하다.

## 현재 SQL 기준 생성 테이블

### users
- 역할: 회원 계정, 로그인, 프로필, 관리자 권한 관리
- 주요 컬럼:
  - `user_no`: 회원 PK
  - `user_id`: 로그인 ID, 중복 불가
  - `user_pw`: 암호화된 비밀번호
  - `user_name`: 닉네임
  - `user_email`: 이메일
  - `user_img`: 프로필 이미지
  - `user_bio`: 자기소개
  - `user_role`: USER 또는 ADMIN
  - `join_date`: 가입일
  - `user_addr1`, `user_addr2`, `user_zipcode`: Mapper와 VO에서 사용하는 주소 필드
- 관련 기능:
  - 회원가입, 로그인, 이메일 인증, 프로필 수정, 비밀번호 변경, 관리자 권한 변경

### media_video_cache
- 역할: TMDB 또는 YouTube fallback으로 찾은 예고편 결과 캐싱
- 주요 컬럼:
  - `cache_no`: 캐시 PK
  - `tmdb_id`: TMDB 콘텐츠 ID
  - `media_type`: movie 또는 tv
  - `season_no`: 드라마 시즌 번호
  - `source_type`: TMDB_V3 또는 YOUTUBE_V3
  - `video_key`: YouTube 영상 key
  - `video_name`: 영상 제목
  - `video_site`: YouTube
  - `video_type`: Trailer, Teaser 등
  - `display_order`: 노출 순서
  - `reg_date`: 저장일
- 관련 기능:
  - 영화 예고편, 드라마 예고편, 시즌별 예고편 fallback
- 제약:
  - `(media_type, tmdb_id, season_no, video_key)` 조합 중복 방지

## Mapper 기준 추가 필요 테이블

아래 테이블들은 현재 `springGreen8.sql`에는 `CREATE TABLE` 문이 없지만, Mapper XML과 VO에서 실제 기능 구현에 사용되는 것으로 확인되는 테이블이다. Claude Desktop에 PPT를 요청할 때는 "현재 DDL에 없는 코드 참조 테이블"이라고 설명해야 한다.

### movie
- 역할: TMDB 콘텐츠를 내부 기능과 연결하기 위한 로컬 영화 테이블
- 관련 기능:
  - 리뷰, 찜 목록, 마이페이지, 관리자 리뷰 목록과 연결
- 구현 포인트:
  - 리뷰 작성 또는 찜 등록 시 내부 DB에 콘텐츠가 없으면 TMDB에서 상세 정보를 가져와 `movie` 테이블에 저장한 뒤 내부 PK로 연결한다.

### review
- 역할: 콘텐츠별 사용자 리뷰 저장
- 관련 기능:
  - 리뷰 작성, 수정, 삭제, 정렬, 별점 통계, 관리자 리뷰 관리, 신고 처리

### review_like
- 역할: 리뷰 좋아요 중복 방지 및 좋아요 수 계산
- 관련 기능:
  - 리뷰 좋아요 토글
- 구현 포인트:
  - 좋아요를 추가/취소한 뒤 `review_like` 개수를 다시 계산해 `review.like_cnt`를 갱신한다.

### comment
- 역할: 리뷰에 대한 댓글 저장
- 관련 기능:
  - 댓글 작성, 목록 조회, 수정, 삭제
- 구현 포인트:
  - 댓글 작성 시 리뷰 작성자 본인이 아니면 알림 테이블에 댓글 알림을 생성한다.

### watchlist
- 역할: 사용자의 찜 목록과 상태 저장
- 관련 기능:
  - 찜 추가/취소, 마이페이지 찜 목록, 상태 변경
- 구현 포인트:
  - 화면에서는 TMDB ID를 받지만 서비스에서 `movie.tmdb_id -> movie.movie_no`로 변환해 저장한다.

### watched
- 역할: 사용자가 본 콘텐츠 기록 저장
- 관련 기능:
  - 봤어요 추가/취소, 봤어요 여부 확인, 내 봤어요 목록

### collection
- 역할: 사용자별 콘텐츠 컬렉션 저장
- 관련 기능:
  - 컬렉션 생성, 수정, 삭제, 내 컬렉션 목록, 공개 컬렉션 목록

### collection_movie
- 역할: 컬렉션과 콘텐츠의 다대다 연결
- 관련 기능:
  - 컬렉션에 콘텐츠 추가/제거, 컬렉션 상세 콘텐츠 목록

### report
- 역할: 사용자 신고 저장 및 관리자 처리
- 관련 기능:
  - 신고 등록, 중복 신고 방지, 관리자 신고 목록, 신고 상태 변경
- 구현 포인트:
  - 리뷰 신고가 PROCESSED로 처리되면 해당 리뷰 본문을 블라인드 문구로 변경한다.

### notification
- 역할: 댓글/좋아요/리뷰 등 사용자 알림 저장
- 관련 기능:
  - 미읽음 알림 수, 알림 목록, 단건 읽음, 전체 읽음

### search_history
- 역할: 사용자 검색 기록과 인기 검색어 집계
- 관련 기능:
  - 최근 검색어, 최근 검색어 삭제, 전체 삭제, 인기 검색어
- 구현 포인트:
  - 검색 첫 페이지에서만 기록을 저장하고, 같은 키워드는 삭제 후 다시 저장해 중복 적재를 줄인다.

## DB 관계 요약

아래 관계는 `springGreen8.sql`에 정의된 FK가 아니라, Mapper SQL과 VO 필드 기준으로 코드가 참조하는 관계를 정리한 것이다. 현재 SQL 파일만 기준으로는 `users`, `media_video_cache` 두 테이블만 생성된다.

```text
users.user_no
  -> review.user_no
  -> comment.user_no
  -> review_like.user_no
  -> watchlist.user_no
  -> search_history.user_no

users.user_id
  -> collection.mid
  -> watched.mid
  -> report.reporter_mid
  -> notification.receiver_mid / sender_mid

movie.movie_no
  -> review.movie_no
  -> watchlist.movie_no

review.review_no
  -> comment.review_no
  -> review_like.review_no
  -> report.target_id when target_type = REVIEW

collection.collection_id
  -> collection_movie.collection_id

TMDB ID
  -> movie.tmdb_id
  -> watched.movie_id
  -> collection_movie.movie_id
  -> media_video_cache.tmdb_id
```

## 기능 구현 흐름 요약

### 1. 메인 화면
- 진입 URL: `/`, `/h`
- Controller: `HomeController`
- Service: `TmdbService`
- View: `home.jsp`
- 구현 흐름:
  - 인기 영화, 현재 상영작, 주간 트렌딩, 개봉 예정작을 TMDB API에서 조회한다.
  - 조회 결과를 모델에 담아 홈 화면에 출력한다.

### 2. 콘텐츠 목록
- 진입 URL:
  - `/movie/list`
  - `/movie/tv`
  - `/movie/animation`
  - `/movie/all`
- Controller: `MovieController`
- Service: `TmdbServiceImpl`
- View:
  - `movie/list.jsp`
  - `movie/tvList.jsp`
  - `movie/animationList.jsp`
  - `movie/allList.jsp`
- 구현 흐름:
  - 영화, 드라마, 애니메이션을 탭과 국가 필터 기준으로 조회한다.
  - 인기, 현재 상영/방영, 평점순, 애니메이션 영화/TV 등으로 분기한다.

### 3. 검색 기능
- 진입 URL: `/movie/search`
- Controller: `MovieController.search`
- Service: `TmdbServiceImpl.searchContents`
- DAO: `SearchHistoryDAO`
- Mapper: `SearchHistoryMapper.xml`
- View: `movie/search.jsp`
- 구현 흐름:
  - 검색어를 trim 처리한다.
  - `#`이 포함된 경우 제목 검색어와 키워드 검색어를 분리한다.
  - 제목 검색을 먼저 수행한다.
  - 결과 품질이 낮으면 제목 fallback 검색을 수행한다.
  - 키워드 검색어가 있으면 TMDB keyword 검색과 discover API를 사용한다.
  - 로그인 사용자는 첫 페이지 검색 시 최근 검색어를 저장한다.
  - 중복 최근 검색어는 삭제 후 다시 저장한다.
- 발표 포인트:
  - 단순 문자열 검색이 아니라 제목 보정, `# 키워드`, 키워드 fallback, 최근 검색어 처리를 결합했다.

### 4. 영화 상세
- 진입 URL: `/movie/detail/{tmdbId}`
- Controller: `MovieController.detail`
- Service: `TmdbServiceImpl`
- DAO:
  - `MovieDAO`
  - `ReviewService`
  - `WatchlistService`
- View: `movie/detail.jsp`
- 구현 흐름:
  - TMDB에서 영화 상세, 출연진, 스태프, 예고편, 키워드, OTT 제공처를 조회한다.
  - 로그인 사용자는 내부 DB의 movie 테이블과 연결해 내 리뷰와 찜 상태를 함께 조회한다.

### 5. 드라마 상세
- 진입 URL: `/movie/tv/{tmdbId}`
- Controller: `MovieController.tvDetail`
- Service: `TmdbServiceImpl`
- View: `movie/tvDetail.jsp`
- 구현 흐름:
  - 드라마 상세, 시즌 정보, 키워드, 출연진, 스태프, OTT 제공처를 조회한다.
  - 시즌 번호가 없으면 첫 번째 일반 시즌을 기본 선택한다.
  - 선택 시즌 영상이 없으면 시즌 1 영상으로 fallback한다.
  - 그래도 없으면 시리즈 전체 예고편으로 fallback한다.

### 6. 예고편 처리 알고리즘
- 핵심 구현 파일: `TmdbServiceImpl`
- 관련 테이블: `media_video_cache`
- 구현 흐름:
  - 먼저 TMDB 한국어 영상 목록을 조회한다.
  - 결과가 없으면 TMDB 영어 영상 목록을 조회한다.
  - TMDB 결과가 있으면 재생 가능 여부를 확인하고 캐시에 저장한다.
  - TMDB 결과가 부족하면 YouTube 캐시를 확인한다.
  - 캐시도 없으면 YouTube 검색 fallback을 수행한다.
  - YouTube 후보 중 쇼츠, 리뷰, OST, 클립, 해설 영상 등 예고편이 아닌 결과를 제외한다.
  - 제목 일치, 채널명 일치, official 포함 여부, trailer/teaser/preview 계열 여부, 시즌 정보 일치 여부로 점수화한다.
  - 가능하면 YouTube 상세 API로 임베드 가능, 공개 상태, 업로드 처리 상태, 한국 지역 재생 가능 여부를 확인한다.
  - 최종 후보를 정렬하고 캐시에 저장한다.
- 발표 포인트:
  - 예고편 기능은 단순 API 호출이 아니라 `TMDB -> 캐시 -> YouTube fallback -> 후보 필터링 -> 점수화 -> 재생 검증 -> 캐시` 구조다.

### 7. 회원 기능
- 진입 URL:
  - `/user/join`
  - `/user/login`
  - `/user/logout`
  - `/user/mypage`
  - `/user/edit`
  - `/user/changePw`
  - `/user/findId`
  - `/user/findPw`
- Controller: `UserController`
- Service: `UserServiceImpl`, `EmailService`
- DAO: `UserDAO`
- Mapper: `UserMapper.xml`
- View:
  - `user/join.jsp`
  - `user/login.jsp`
  - `user/mypage.jsp`
  - `user/edit.jsp`
  - `user/findId.jsp`
  - `user/findPw.jsp`
- 구현 흐름:
  - 회원가입 시 아이디, 비밀번호, 이메일, 닉네임 검증을 수행한다.
  - 이메일 인증 코드는 `EmailService`에서 6자리 숫자로 생성해 발송한다.
  - 비밀번호는 SHA-256으로 해시 처리해 저장한다.
  - 로그인 실패는 메모리 Map으로 카운트하고 5회 실패 시 10분 잠금 처리한다.
  - 로그인 성공 시 기존 세션을 무효화하고 새 세션에 `loginUser`를 저장한다.
  - 마이페이지에서는 내 리뷰, 찜 목록, 평균 별점을 조회한다.

### 8. 리뷰 기능
- 진입 URL:
  - `/review/write`
  - `/review/list`
  - `/review/update`
  - `/review/delete`
  - `/review/like`
  - `/review/list/sorted`
  - `/review/stats`
- Controller: `ReviewController`
- Service: `ReviewServiceImpl`
- DAO: `ReviewDAO`, `MovieDAO`
- Mapper: `ReviewMapper.xml`, `MovieMapper.xml`
- 관련 테이블: `review`, `review_like`, `movie`, `users`
- 구현 흐름:
  - 리뷰 작성 전 로그인 여부와 내용 길이를 검사한다.
  - TMDB ID로 내부 `movie` row를 찾고, 없으면 TMDB 상세 정보를 조회해 `movie`에 저장한다.
  - 리뷰는 내부 `movie_no`를 기준으로 저장한다.
  - 수정과 삭제는 원본 리뷰를 조회해 작성자 권한을 확인한다.
  - 삭제는 작성자 또는 관리자만 가능하다.
  - 좋아요는 본인 리뷰에는 불가능하고, `review_like`에서 토글 후 `like_cnt`를 갱신한다.

### 9. 댓글과 알림 기능
- 진입 URL:
  - `/comment/write`
  - `/comment/list`
  - `/comment/update`
  - `/comment/delete`
  - `/notification/count`
  - `/notification/list`
  - `/notification/read`
  - `/notification/readAll`
- Controller: `CommentController`, `NotificationController`
- Service/DAO: `CommentService`, `NotificationDAO`
- 관련 테이블: `comment`, `notification`, `review`, `users`, `movie`
- 구현 흐름:
  - 댓글 작성 시 로그인 여부와 댓글 길이를 검사한다.
  - 댓글 저장 후 리뷰 작성자가 본인이 아니면 알림을 생성한다.
  - 알림은 받는 사람, 보낸 사람, 타입, 참조 ID, 메시지, 읽음 여부를 저장한다.

### 10. 찜 기능
- 진입 URL: `/movie/watchlist`
- Controller: `MovieController.toggleWatchlist`
- Service: `WatchlistServiceImpl`
- DAO: `WatchlistDAO`, `MovieDAO`
- 관련 테이블: `watchlist`, `movie`
- 구현 흐름:
  - 화면에서 받은 TMDB ID를 내부 `movie_no`로 변환한다.
  - 내부 `movie` 데이터가 없으면 TMDB 상세 정보를 저장한다.
  - 이미 찜한 콘텐츠면 삭제하고, 없으면 `WANT` 상태로 추가한다.

### 11. 봤어요 기능
- 진입 URL:
  - `/movie/watched/toggle`
  - `/movie/watched/check`
- Controller: `MovieController`
- Service: `WatchedServiceImpl`
- DAO: `WatchedDAO`
- 관련 테이블: `watched`
- 구현 흐름:
  - 로그인 사용자의 `user_id`와 TMDB 콘텐츠 ID를 기준으로 저장한다.
  - 이미 있으면 삭제하고 없으면 추가하는 토글 구조다.

### 12. 컬렉션 기능
- 진입 URL:
  - `/collection/list`
  - `/collection/public`
  - `/collection/detail/{collectionId}`
  - `/collection/create`
  - `/collection/update`
  - `/collection/delete`
  - `/collection/movie/toggle`
  - `/collection/my`
- Controller: `CollectionController`
- Service: `CollectionServiceImpl`
- DAO: `CollectionDAO`
- 관련 테이블: `collection`, `collection_movie`
- 구현 흐름:
  - 로그인 사용자는 컬렉션을 생성하고 공개/비공개를 설정할 수 있다.
  - 비공개 컬렉션은 소유자만 접근할 수 있다.
  - 컬렉션 제목은 1~100자, 설명은 500자 이하로 검증한다.
  - 컬렉션에 콘텐츠를 추가할 때 중복 여부를 확인하고 토글한다.

### 13. 신고와 관리자 처리
- 진입 URL:
  - `/report/insert`
  - `/admin/reports`
  - `/admin/report/status`
- Controller: `ReportController`, `AdminController`
- Service: `AdminServiceImpl`
- DAO: `ReportDAO`, `AdminDAO`
- 관련 테이블: `report`, `review`
- 구현 흐름:
  - 신고 등록 시 로그인 여부, 신고 사유 길이, 중복 신고 여부를 검사한다.
  - 관리자는 신고 목록을 확인하고 상태를 변경한다.
  - REVIEW 신고를 PROCESSED 처리하면 해당 리뷰 본문을 블라인드 문구로 변경한다.
  - 상태 변경과 리뷰 블라인드 처리는 트랜잭션으로 묶여 있다.

### 14. 관리자 기능
- 진입 URL:
  - `/admin/dashboard`
  - `/admin/users`
  - `/admin/user/role`
  - `/admin/user/delete`
  - `/admin/reviews`
  - `/admin/review/delete`
  - `/admin/reports`
  - `/admin/report/status`
- Controller: `AdminController`
- Interceptor: `AdminInterceptor`
- Advice: `GlobalViewOptionsAdvice`
- DAO: `AdminDAO`
- 관련 테이블:
  - `users`
  - `review`
  - `comment`
  - `watchlist`
  - `report`
  - `search_history`
- 구현 흐름:
  - `/admin/**` 요청은 `AdminInterceptor`에서 로그인과 ADMIN 권한을 확인한다.
  - 권한이 없으면 일반 요청은 리다이렉트하고 Ajax/JSON 요청은 JSON 오류를 반환한다.
  - 관리자 화면에서는 회원 수, 리뷰 수, 댓글 수, 찜 수, 대기 신고 수를 통계로 조회한다.
  - 회원 권한 변경, 회원 삭제, 리뷰 삭제, 신고 상태 변경을 처리한다.

### 15. 공통 뷰 데이터 주입
- 구현 파일: `GlobalViewOptionsAdvice`
- 역할:
  - 국가 필터 옵션을 모든 화면에 제공한다.
  - 홈, 검색, 관리자 화면에 인기 검색어를 제공한다.
  - 관리자 GET 요청에는 통계와 대기 신고 수를 주입한다.
- 발표 포인트:
  - 반복적으로 필요한 데이터를 각 컨트롤러에 흩어 놓지 않고 공통 Advice에서 관리한다.

### 16. 입력 검증과 XSS 방어
- 구현 파일:
  - `InputValidator.java`
  - `XssFilter.java`
  - `XssRequestWrapper.java`
  - `web.xml`
- 구현 흐름:
  - 회원가입, 로그인, 프로필 수정, 비밀번호 변경, 리뷰/댓글/신고/컬렉션 입력에서 길이와 형식을 검증한다.
  - XSS 필터는 multipart 업로드를 제외한 요청 파라미터를 래핑한다.
  - 위험 태그, 이벤트 핸들러, 위험 URI를 제거하거나 중화하고 HTML escape 처리한다.
  - SQL Injection 위험 패턴과 XSS 위험 패턴은 `InputValidator`에 정리되어 있다.

## 발표에서 강조할 개선 사례

### 검색 개선
- `#` 검색어와 공백이 포함될 때 페이지 이동이 깨지는 문제를 보완했다.
- 검색 첫 페이지에서만 기록을 저장해 페이지 이동 시 최근 검색어가 중복 적재되는 문제를 줄였다.
- 제목 검색이 부족할 때 제목 fallback과 키워드 fallback을 적용했다.

### 예고편 안정성 개선
- TMDB 영상이 비어 있는 경우 YouTube fallback을 적용했다.
- 예고편이 아닌 쇼츠, 리뷰, OST, 클립, 해설 영상을 제외하는 필터를 추가했다.
- 제목, 채널, official, trailer 계열, 시즌 정보 기준으로 후보를 점수화했다.
- 영상 결과를 `media_video_cache`에 저장해 반복 조회 안정성과 속도를 개선했다.

### 관리자 구조 개선
- 관리자 통계를 `GlobalViewOptionsAdvice`에서 공통 주입한다.
- 관리자 요청은 `AdminInterceptor`에서 권한을 일관되게 확인한다.
- 신고 처리와 리뷰 블라인드 처리를 트랜잭션으로 묶었다.

### 입력 검증 개선
- 회원가입, 로그인, 프로필, 비밀번호, 리뷰, 댓글, 신고, 컬렉션 입력 검증을 기능별로 적용했다.
- XSS 필터에서 multipart 요청은 제외해 파일 업로드 손상을 방지했다.
- 위험 태그와 이벤트 속성 중심으로 XSS 처리를 정리했다.

## PPT 추천 목차

1. 표지
2. 프로젝트 한 줄 소개
3. 개발 배경
4. 문제 정의
5. 프로젝트 목표
6. 기술 스택
7. 전체 시스템 구조
8. MVC 계층 구조
9. 현재 SQL 기준 DB 구조
10. SQL에 생성된 2개 테이블: users / media_video_cache
11. Mapper가 참조하는 추가 필요 테이블
12. 코드 참조 기준 테이블 관계도
13. review / comment / review_like 흐름
14. watchlist / watched / collection 흐름
15. report / notification / search_history 흐름
16. media_video_cache와 예고편 캐시 구조
17. 홈과 콘텐츠 탐색 기능
18. 검색 기능 구현
19. 검색 fallback 알고리즘
20. 영화 상세 구현
21. 드라마 상세와 시즌 fallback
22. 예고편 처리 알고리즘
23. YouTube 후보 필터링과 점수화
24. 회원가입/로그인/이메일 인증
25. 마이페이지와 프로필 수정
26. 리뷰 기능 구현
27. 댓글과 알림 기능 구현
28. 찜과 봤어요 기능 구현
29. 컬렉션 기능 구현
30. 신고 기능과 관리자 처리
31. 관리자 대시보드와 권한 제어
32. 입력 검증과 XSS 방어
33. 최근 개선 사례
34. 프로젝트 성과
35. 한계점
36. 향후 개선 방향
37. Q&A

## Claude Desktop에 붙여넣을 최종 프롬프트

```text
너는 대학 프로젝트 발표용 PPT와 포트폴리오형 프로젝트 문서를 설계하는 전문가다.

첨부한 파일들을 참고해서 SpringGreen8 프로젝트 발표용 PPT 초안을 만들어줘.

중요 조건:

1. 슬라이드 수 제한은 없다.
2. 내부 DB 테이블과 기능 구현 방식을 충분히 설명해줘.
3. 단순 기능 소개가 아니라 아래 흐름으로 구성해줘.
   - 문제 정의
   - 프로젝트 목표
   - 시스템 구조
   - DB 테이블 구조
   - 핵심 기능 구현
   - 검색 알고리즘
   - 예고편 처리 알고리즘
   - 사용자 기능
   - 관리자 기능
   - 입력 검증과 보안
   - 개선 사례
   - 결과 / 한계 / 향후 계획
4. `포토폴리오(FIND_KAPOOR).pdf`는 시각적 참고 자료로만 사용해줘.
   - 텍스트를 복제하지 말고
   - 여백감, 섹션 분리, 캡처 중심 레이아웃, 포트폴리오형 정리감만 참고해줘.
5. 발표 톤은 교수님께 설명하는 프로젝트 발표 스타일로, 차분하고 근거 중심의 한국어로 작성해줘.
6. 기능 자랑형 문구보다 "왜 이렇게 설계했고, 어떤 문제를 해결했는지"가 드러나게 해줘.
7. DB 테이블은 다음 기준으로 설명해줘.
   - 현재 springGreen8.sql에 CREATE TABLE로 정의된 테이블은 users, media_video_cache 2개뿐임
   - movie, review, review_like, comment, watchlist, watched, collection, collection_movie, report, notification, search_history는 Mapper/VO가 참조하지만 현재 SQL 파일에는 CREATE TABLE 문이 없음
   - 따라서 실제 생성 테이블과 코드 참조 테이블을 절대 섞어서 말하지 말고, DDL에 없는 테이블은 "Mapper 기준 추가 필요 테이블"이라고 표현해줘.
8. 검색 기능은 반드시 아래 내용을 포함해줘.
   - 제목 검색
   - # 키워드 검색
   - 제목 fallback
   - 키워드 fallback
   - 최근 검색어 저장
   - 인기 검색어
   - 검색 기록 중복 저장 방지
9. 예고편 기능은 반드시 아래 내용을 포함해줘.
   - TMDB ko-KR 영상 조회
   - TMDB en-US 영상 조회
   - media_video_cache 캐시 조회
   - YouTube 검색 fallback
   - 쇼츠, 리뷰, OST, 클립, 해설 영상 제외
   - 제목/채널/official/trailer 계열/시즌 정보 기준 점수화
   - 임베드 가능 여부, 공개 상태, 한국 지역 재생 가능 여부 검증
   - 드라마 시즌 영상 fallback
10. 사용자 기능은 회원가입, 로그인, 이메일 인증, 마이페이지, 프로필 수정, 비밀번호 변경, 리뷰, 댓글, 좋아요, 찜, 봤어요, 컬렉션으로 분리해줘.
11. 관리자 기능은 대시보드, 회원 관리, 리뷰 관리, 신고 처리, 권한 인터셉터, 공통 통계 주입 구조로 설명해줘.
12. 각 슬라이드는 아래 형식으로 작성해줘.
   - 슬라이드 번호
   - 슬라이드 제목
   - 핵심 메시지 1문장
   - 본문 bullet 3~6개
   - 추천 시각 요소
   - 발표 멘트 2~5문장
13. 마지막에는 아래를 따로 정리해줘.
   - 최종 슬라이드 목차
   - 꼭 필요한 화면 캡처 목록
   - 발표 시간이 짧을 때 줄일 수 있는 슬라이드
   - 발표 시간이 충분할 때 추가하면 좋은 심화 슬라이드

결과물은 실제 PPT에 옮기기 좋게 짧고 정돈된 문장으로 작성해줘.
한 슬라이드에 내용이 많으면 억지로 압축하지 말고 슬라이드를 나누어줘.
```

## Claude Desktop 후속 요청 문장

```text
위 초안을 실제 PPT에 들어갈 문구처럼 더 짧게 다듬어줘.
```

```text
각 슬라이드별 발표 대본을 10분 발표 버전으로 만들어줘.
```

```text
각 슬라이드별 발표 대본을 15분 발표 버전으로 만들어줘.
```

```text
DB 테이블 설명 슬라이드만 ERD 중심으로 다시 구성해줘.
```

```text
기능 구현 설명 슬라이드만 Controller-Service-DAO-Mapper 흐름도로 다시 구성해줘.
```

```text
포토폴리오 PDF 느낌에 맞춰 표지, 목차, 섹션 구분 슬라이드 레이아웃을 제안해줘.
```
