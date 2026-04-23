<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<c:set var="blindReviewMessage" value="신고로 인해 블라인드 처리된 리뷰입니다."/>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>마이페이지 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    :root{
      --watcha-point:#ff2f6e; --watcha-point-dark:#f22463;
      --watcha-point-soft:#fff1f5; --watcha-bg:#f7f7f8;
      --watcha-card:#ffffff; --watcha-text:#1f2937;
      --watcha-sub:#6b7280; --watcha-line:#e5e7eb;
      --watcha-shadow:0 18px 40px rgba(0,0,0,0.08);
      --watcha-yellow:#f59e0b; --watcha-blue:#3b82f6;
      --watcha-green:#10b981; --watcha-gray:#9ca3af;
    }
    body{ background:linear-gradient(180deg,#fbfbfc 0%,#f4f5f7 100%) !important;
          color:var(--watcha-text) !important;
          font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif; }
    a{ text-decoration:none; }
    .mypage-wrap{ padding:42px 0 60px 0; }
    .profile-img{ width:96px;height:96px;object-fit:cover;border-radius:50%;
                  border:4px solid #fff;box-shadow:0 8px 20px rgba(0,0,0,0.10);background:#f3f4f6; }
    .movie-poster{ width:100%;height:220px;object-fit:cover;border-radius:16px;background:#f3f4f6; }
    .movie-card{ cursor:pointer;transition:all 0.22s ease; }
    .movie-card:hover{ transform:translateY(-4px); }
    .section-title{ font-size:1.25rem;font-weight:800;color:#111827;margin-bottom:0; }
    .profile-card{ background:var(--watcha-card);border:1px solid #f0f0f0;border-radius:28px;
                   box-shadow:var(--watcha-shadow);overflow:hidden; }
    .profile-head{ padding:34px;background:linear-gradient(135deg,#fff5f8 0%,#ffffff 55%,#fff8fb 100%); }
    .profile-name{ font-size:1.6rem;font-weight:800;color:#111827;margin-bottom:4px; }
    .profile-email{ font-size:14px;color:var(--watcha-sub);margin-bottom:6px; }
    .profile-text{ font-size:14px;color:#4b5563;margin-bottom:4px;line-height:1.6; }
    .edit-btn{ border-radius:999px;padding:10px 18px;font-size:14px;font-weight:700;
               border:1px solid #ffd1df;color:var(--watcha-point);background:#fff;transition:all 0.2s ease; }
    .edit-btn:hover{ background:var(--watcha-point-soft);color:var(--watcha-point-dark);border-color:#ffb7cb; }
    .stat-card{ background:var(--watcha-card);border:1px solid #f0f0f0;border-radius:20px;
                padding:22px 16px;box-shadow:0 6px 18px rgba(0,0,0,0.05);height:100%; }
    .stat-value{ font-size:1.7rem;font-weight:800;margin-bottom:4px;color:#111827; }
    .stat-label{ font-size:13px;color:var(--watcha-sub);font-weight:600; }
    .tab-wrap{ display:flex;gap:10px;margin-bottom:24px;flex-wrap:wrap; }
    .tab-btn{ background:#fff;border:1px solid #ececec;color:var(--watcha-sub);
              font-size:15px;font-weight:700;padding:10px 18px;border-radius:999px;
              cursor:pointer;transition:all 0.2s ease; }
    .tab-btn.active{ color:#fff;background:var(--watcha-point);border-color:var(--watcha-point);
                     box-shadow:0 8px 20px rgba(255,47,110,0.18); }
    .review-card{ background:#fff;border-radius:20px;border:1px solid #efefef;
                  box-shadow:0 6px 18px rgba(0,0,0,0.05); }
    .review-title{ font-size:16px;font-weight:800;color:#111827;margin-bottom:6px; }
    .review-content{ color:#4b5563 !important;line-height:1.65;word-break:break-word; }
    .review-content.blind{ display:inline-flex; align-items:center; gap:8px; padding:10px 14px; border-radius:14px; background:#fff1f2; border:1px solid #fecdd3; color:#be123c !important; font-weight:700; }
    .review-card.blind{ border-color:#fecdd3; background:linear-gradient(180deg,#fff7f8 0%,#ffffff 100%); }
    .review-date{ color:var(--watcha-sub) !important;font-size:13px; }
    .poster-sm{ width:64px;height:96px;object-fit:cover;border-radius:10px;background:#f3f4f6; }
    .watch-card{ background:#fff;border:1px solid #efefef;border-radius:18px;padding:10px;
                 box-shadow:0 6px 18px rgba(0,0,0,0.05);transition:all 0.22s ease;height:100%; }
    .watch-card:hover{ transform:translateY(-4px);box-shadow:0 14px 28px rgba(0,0,0,0.08); }
    .watch-title{ font-size:14px;font-weight:800;color:#111827;margin-bottom:8px; }
    .status-badge{ display:inline-block;font-size:11px;padding:5px 10px;
                   border-radius:999px;font-weight:700;line-height:1.2; }
    .empty-box{ background:#fff;border:1px dashed #e5e7eb;border-radius:24px;
                padding:54px 20px;text-align:center; }
    .empty-box i{ color:#d1d5db !important; }
    .empty-text{ color:var(--watcha-sub);margin-bottom:16px; }
    .go-btn{ border-radius:999px;padding:10px 18px;font-size:14px;font-weight:700;
             background:var(--watcha-point);border:none;color:#fff; }
    .go-btn:hover{ background:var(--watcha-point-dark);color:#fff; }
    .action-row{ display:flex;justify-content:center;gap:12px;flex-wrap:wrap; }
    .logout-btn,.withdraw-btn{ border-radius:999px;padding:10px 22px;font-weight:700; }
    .withdraw-btn{ border-color:#d1d5db;color:#374151;background:#fff; }
    .withdraw-btn:hover{ background:#f9fafb;color:#111827;border-color:#9ca3af; }
    .withdraw-warn{ background:#fff5f5;border:1px solid #fecaca;border-radius:16px;padding:14px 16px;
                    color:#b91c1c;font-size:14px;line-height:1.6; }
    .withdraw-note{ color:#6b7280;font-size:13px;line-height:1.6; }
    /* 봤어요 카드 */
    .watched-card{ background:#fff;border:1px solid #efefef;border-radius:18px;padding:10px;
                   box-shadow:0 6px 18px rgba(0,0,0,0.05);transition:all 0.22s ease;
                   cursor:pointer;height:100%; }
    .watched-card:hover{ transform:translateY(-4px);box-shadow:0 14px 28px rgba(0,0,0,0.08); }
    .watched-card img{ width:100%;aspect-ratio:2/3;object-fit:cover;border-radius:12px; }
    .watched-title{ font-size:13px;font-weight:700;color:#111827;margin-top:8px;
                    white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
    /* 컬렉션 카드 */
    .col-card{ background:#fff;border:1px solid #efefef;border-radius:20px;
               padding:20px;box-shadow:0 6px 18px rgba(0,0,0,0.05);
               transition:all 0.22s ease;cursor:pointer;height:100%; }
    .col-card:hover{ transform:translateY(-3px);box-shadow:0 14px 28px rgba(0,0,0,0.08);
                     border-color:#ffd1df; }
    .col-title{ font-size:15px;font-weight:800;color:#111827;margin-bottom:6px; }
    .col-desc{ font-size:13px;color:var(--watcha-sub);margin-bottom:10px;
               white-space:nowrap;overflow:hidden;text-overflow:ellipsis; }
    .col-meta{ font-size:12px;color:#9ca3af; }
    .badge-pub{ background:rgba(16,185,129,0.12);color:#059669;
                padding:3px 8px;border-radius:999px;font-size:11px;font-weight:700; }
    .badge-pri{ background:rgba(156,163,175,0.15);color:#6b7280;
                padding:3px 8px;border-radius:999px;font-size:11px;font-weight:700; }
    @media (max-width:767px){
      .mypage-wrap{ padding-top:24px; }
      .profile-head{ padding:24px 20px; }
      .profile-name{ font-size:1.35rem; }
      .movie-poster{ height:200px; }
    }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container mypage-wrap">

  <!-- 프로필 카드 -->
  <div class="profile-card mb-4">
    <div class="profile-head">
      <div class="row align-items-center g-3">
        <div class="col-auto">
          <img src="${ctp}/data/${user.userImg}" class="profile-img"
               onerror="this.src='https://placehold.co/96x96?text=User'">
        </div>
        <div class="col">
          <h4 class="profile-name">${fn:escapeXml(user.userName)}</h4>
          <p class="profile-email">${fn:escapeXml(user.userEmail)}</p>
          <c:if test="${not empty user.userZipcode}">
            <p class="profile-text mb-1">[${fn:escapeXml(user.userZipcode)}] ${fn:escapeXml(user.userAddr1)} ${fn:escapeXml(user.userAddr2)}</p>
          </c:if>
          <c:if test="${not empty user.userBio}">
            <p class="profile-text mb-0">${fn:escapeXml(user.userBio)}</p>
          </c:if>
        </div>
        <div class="col-12 col-md-auto text-md-end">
          <a href="${ctp}/user/edit" class="btn edit-btn">프로필 수정</a>
        </div>
      </div>
    </div>
  </div>

  <!-- 통계 -->
  <div class="row g-3 mb-4 text-center">
    <div class="col-3">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-point);">${reviewList.size()}</h3>
        <div class="stat-label">작성한 리뷰</div>
      </div>
    </div>
    <div class="col-3">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-point);">${watchList.size()}</h3>
        <div class="stat-label">찜한 영화</div>
      </div>
    </div>
    <div class="col-3">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-blue);" id="watchedCount">${watchedList.size()}</h3>
        <div class="stat-label">봤어요</div>
      </div>
    </div>
    <div class="col-3">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-yellow);">
          <c:choose>
            <c:when test="${not empty avgRating}">★ ${avgRating}</c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </h3>
        <div class="stat-label">평균 별점</div>
      </div>
    </div>
  </div>

  <!-- 탭 메뉴 -->
  <div class="tab-wrap">
    <button class="tab-btn active" onclick="switchTab(this,'reviews')">
      내 리뷰 <span class="badge rounded-pill bg-light text-dark ms-1">${reviewList.size()}</span>
    </button>
    <button class="tab-btn" onclick="switchTab(this,'watchlist')">
      찜 목록 <span class="badge rounded-pill bg-light text-dark ms-1">${watchList.size()}</span>
    </button>
    <button class="tab-btn" onclick="switchTab(this,'watched')">
      봤어요 <span id="watchedTabCount" class="badge rounded-pill bg-light text-dark ms-1">${watchedList.size()}</span>
    </button>
    <button class="tab-btn" onclick="switchTab(this,'collections'); loadCollections()">
      내 컬렉션 <span id="collectionTabCount" class="badge rounded-pill bg-light text-dark ms-1">${collectionCount}</span>
    </button>
  </div>

  <!-- 내 리뷰 탭 -->
  <div id="tab-reviews">
    <c:choose>
      <c:when test="${not empty reviewList}">
        <c:forEach var="review" items="${reviewList}">
          <div class="review-card p-3 mb-3 ${review.content == blindReviewMessage ? 'blind' : ''}">
            <div class="row align-items-center g-3">
              <div class="col-auto">
                <img src="https://image.tmdb.org/t/p/w200${review.posterPath}"
                     class="poster-sm"
                     onerror="this.src='https://placehold.co/64x96?text=No'">
              </div>
              <div class="col">
                <h6 class="review-title">${fn:escapeXml(review.title)}</h6>
                <div class="mb-1">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                      <c:when test="${i <= review.rating}"><span style="color:var(--watcha-yellow);">★</span></c:when>
                      <c:otherwise><span style="color:#d1d5db;">★</span></c:otherwise>
                    </c:choose>
                  </c:forEach>
                  <span class="small ms-1" style="color:var(--watcha-yellow);font-weight:700;">${review.rating}점</span>
                </div>
                <c:choose>
                  <c:when test="${review.content == blindReviewMessage}">
                    <p class="review-content blind small mb-0"><i class="fa fa-eye-slash"></i> 블라인드 처리된 리뷰</p>
                  </c:when>
                  <c:otherwise>
                    <p class="review-content small mb-0">${fn:escapeXml(review.content)}</p>
                  </c:otherwise>
                </c:choose>
              </div>
              <div class="col-12 col-md-auto text-md-end">
                <small class="review-date">
                  <fmt:formatDate value="${review.regDate}" pattern="yyyy-MM-dd"/>
                </small>
              </div>
            </div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <div class="empty-box">
          <i class="fa fa-pencil fa-3x mb-3"></i>
          <p class="empty-text">작성한 리뷰가 없습니다.</p>
          <a href="${ctp}/movie/list" class="btn go-btn">영화 보러가기</a>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- 찜 목록 탭 -->
  <div id="tab-watchlist" style="display:none;">
    <c:choose>
      <c:when test="${not empty watchList}">
        <div class="row g-3">
          <c:forEach var="watch" items="${watchList}">
            <div class="col-6 col-md-3 col-lg-2">
              <div class="movie-card"
                   onclick="location.href='${ctp}/movie/detail/${watch.tmdbId}'">
                <div class="watch-card">
                  <img src="https://image.tmdb.org/t/p/w500${watch.posterPath}"
                       class="movie-poster mb-2"
                       onerror="this.src='https://placehold.co/200x220?text=No+Image'">
                  <p class="watch-title text-truncate">${watch.title}</p>
                  <c:choose>
                    <c:when test="${watch.status == 'WANT'}">
                      <span class="status-badge text-white" style="background:var(--watcha-point);">보고싶어요</span>
                    </c:when>
                    <c:when test="${watch.status == 'WATCHED'}">
                      <span class="status-badge text-white" style="background:var(--watcha-blue);">봤어요</span>
                    </c:when>
                    <c:otherwise>
                      <span class="status-badge text-white" style="background:var(--watcha-gray);">그만볼래요</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="empty-box">
          <i class="fa fa-heart fa-3x mb-3"></i>
          <p class="empty-text">찜한 영화가 없습니다.</p>
          <a href="${ctp}/movie/list" class="btn go-btn">영화 보러가기</a>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- 봤어요 탭 -->
  <div id="tab-watched" style="display:none;">
    <c:choose>
      <c:when test="${not empty watchedList}">
        <div class="row g-3">
          <c:forEach var="watched" items="${watchedList}">
            <div class="col-6 col-md-3 col-lg-2">
              <div class="watched-card" onclick="location.href='${ctp}/movie/detail/${watched.movieId}'">
                <c:choose>
                  <c:when test="${not empty watched.posterPath}">
                    <img src="https://image.tmdb.org/t/p/w200${watched.posterPath}"
                         data-tmdb="${watched.movieId}"
                         data-needs-fetch="${empty watched.title or empty watched.posterPath}"
                         onerror="this.src='https://placehold.co/120x180?text=No+Image'">
                  </c:when>
                  <c:otherwise>
                    <img src="https://placehold.co/120x180?text=No+Image"
                         data-tmdb="${watched.movieId}"
                         data-needs-fetch="true"
                         onerror="this.src='https://placehold.co/120x180?text=No+Image'">
                  </c:otherwise>
                </c:choose>
                <div class="watched-title" id="wt-${watched.movieId}">
                  <c:choose>
                    <c:when test="${not empty watched.title}">${fn:escapeXml(watched.title)}</c:when>
                    <c:otherwise>Loading...</c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="empty-box">
          <i class="fa fa-check-circle fa-3x mb-3"></i>
          <p class="empty-text">봤어요 목록이 없습니다.</p>
          <a href="${ctp}/movie/list" class="btn go-btn">영화 보러가기</a>
        </div>
      </c:otherwise>
    </c:choose>
    <div id="watchedGrid" class="row g-3" style="display:none;">
      <div class="col-12 text-center py-4 text-secondary">불러오는 중...</div>
    </div>
  </div>

  <!-- 내 컬렉션 탭 -->
  <div id="tab-collections" style="display:none;">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <span class="section-title">내 컬렉션</span>
      <button class="btn go-btn btn-sm" onclick="openCreateModal()">+ 새 컬렉션</button>
    </div>
    <div id="collectionGrid" class="row g-3">
      <div class="col-12 text-center py-4 text-secondary">불러오는 중...</div>
    </div>
  </div>

  <!-- 로그아웃 -->
  <div class="text-center mt-5">
    <a href="${ctp}/user/logout" class="btn btn-outline-danger logout-btn">로그아웃</a>
  </div>
</div>

<!-- 컬렉션 생성 모달 -->
<div class="modal fade" id="createColModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content bg-white">
      <div class="modal-header">
        <h5 class="modal-title text-dark">새 컬렉션 만들기</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label text-dark fw-bold">제목 *</label>
          <input type="text" id="colTitle" class="form-control"
                 placeholder="컬렉션 이름" maxlength="100">
        </div>
        <div class="mb-3">
          <label class="form-label text-dark fw-bold">설명</label>
          <textarea id="colDesc" class="form-control" rows="3"
                    placeholder="컬렉션 설명 (선택)" maxlength="500"></textarea>
        </div>
        <div class="form-check">
          <input class="form-check-input" type="checkbox" id="colPublic" checked>
          <label class="form-check-label text-dark">공개 컬렉션</label>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button class="btn" style="background:var(--watcha-point);color:#fff;"
                onclick="createCollection()">만들기</button>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="withdrawModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content bg-white">
      <form id="withdrawForm" action="${ctp}/user/withdraw" method="post">
        <div class="modal-header border-0 pb-0">
          <h5 class="modal-title text-dark fw-bold">회원 탈퇴</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body pt-2">
          <div class="withdraw-warn mb-3">
            탈퇴 후에는 계정 복구가 어렵고, 찜·봤어요·컬렉션·알림 같은 개인 데이터가 함께 삭제됩니다.
          </div>
          <p class="withdraw-note mb-3">
            작성한 리뷰와 댓글은 다른 이용자 화면에서 <strong>탈퇴한 사용자</strong>로 익명 보존되고, 계정 자체는 실제 삭제됩니다.
          </p>
          <c:if test="${user.loginProvider ne 'KAKAO'}">
            <label for="withdrawCurrentPw" class="form-label text-dark fw-bold">현재 비밀번호</label>
            <input type="password" id="withdrawCurrentPw" name="currentPw"
                   class="form-control" maxlength="20" autocomplete="current-password"
                   placeholder="현재 비밀번호를 입력해주세요.">
          </c:if>
          <c:if test="${user.loginProvider eq 'KAKAO'}">
            <p class="withdraw-note mb-0">
              카카오 전용 계정은 비밀번호 입력 없이 현재 로그인 상태에서 탈퇴가 진행됩니다.
            </p>
          </c:if>
        </div>
        <div class="modal-footer border-0 pt-0">
          <button type="button" class="btn btn-light" data-bs-dismiss="modal">취소</button>
          <button type="submit" class="btn btn-danger">회원 탈퇴</button>
        </div>
      </form>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
var ctp = '${ctp}';
var TMDB_IMG = 'https://image.tmdb.org/t/p/w200';
var watchedLoaded = false, colLoaded = false;
var withdrawPasswordRequired = '${user.loginProvider}' !== 'KAKAO';

function escapeHtml(value) {
    return $('<div>').text(value == null ? '' : String(value)).html();
}

function ensureWithdrawAction() {
    var logoutBtn = document.querySelector('.logout-btn');
    if (!logoutBtn) return;

    logoutBtn.textContent = '로그아웃';

    var wrapper = logoutBtn.parentElement;
    if (!wrapper) return;

    wrapper.className = 'action-row mt-5';

    if (document.getElementById('withdrawActionBtn')) return;

    var button = document.createElement('button');
    button.type = 'button';
    button.id = 'withdrawActionBtn';
    button.className = 'btn withdraw-btn';
    button.setAttribute('data-bs-toggle', 'modal');
    button.setAttribute('data-bs-target', '#withdrawModal');
    button.textContent = '회원 탈퇴';
    wrapper.appendChild(button);
}

/* ── 탭 전환 ── */
function switchTab(btn, tabName) {
    ['reviews','watchlist','watched','collections'].forEach(function(t) {
        var el = document.getElementById('tab-' + t);
        if (el) el.style.display = 'none';
    });
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('tab-' + tabName).style.display = 'block';
    btn.classList.add('active');
}

/* ── 봤어요 목록 로드 ── */
function loadWatched() {
    if (watchedLoaded) return;
    watchedLoaded = true;
    $.get(ctp + '/collection/my', function() {}, 'json'); // 워밍업
    $.ajax({
        url: ctp + '/movie/watched/check',
        type: 'GET',
        data: { movieNo: 0 },
        complete: function() {}
    });
    // WatchedController GET /watched/list 호출
    $.get(ctp + '/watched/list', function(list) {
        if (!list || list.length === 0) {
            $('#watchedGrid').html(
                '<div class="col-12"><div class="empty-box">' +
                '<i class="fa fa-check-circle fa-3x mb-3"></i>' +
                '<p class="empty-text">봤어요 목록이 없습니다.</p>' +
                '<a href="' + ctp + '/movie/list" class="btn go-btn">영화 보러가기</a>' +
                '</div></div>'
            );
            $('#watchedCount').text(0);
            return;
        }
        $('#watchedCount').text(list.length);
        var html = '';
        list.forEach(function(w) {
            var title = w.title || '제목 준비중...';
            var posterSrc = w.posterPath ? (TMDB_IMG + w.posterPath) : 'https://placehold.co/120x180?text=No+Image';
            var needsFetch = !w.title || !w.posterPath;
            html += '<div class="col-6 col-md-3 col-lg-2">';
            html += '<div class="watched-card" onclick="location.href=\'' + ctp + '/movie/detail/' + w.movieId + '\'">';
            html += '<img src="' + posterSrc + '" data-tmdb="' + w.movieId + '" data-needs-fetch="' + (needsFetch ? 'true' : 'false') + '"';
            html += ' onerror="this.src=\'https://placehold.co/120x180?text=No+Image\'">';
            html += '<div class="watched-title" id="wt-' + w.movieId + '">로딩중...</div>';
            html += '</div></div>';
        });
        $('#watchedGrid').html(html);
        list.forEach(function(w) {
            var titleEl = document.getElementById('wt-' + w.movieId);
            if (titleEl) titleEl.textContent = w.title || 'Loading...';
        });

        // TMDB 포스터 로딩
        $('img[data-needs-fetch="true"]').each(function() {
            var id = $(this).data('tmdb');
            var imgEl = this;
            fetch(ctp + '/movie/api/' + id)
                .then(function(r) { return r.json(); })
                .then(function(d) {
                    if (d.posterPath) imgEl.src = TMDB_IMG + d.posterPath;
                    var t = document.getElementById('wt-' + id);
                    if (t && d.title) t.textContent = d.title;
                });
        });
    }, 'json').fail(function() {
        $('#watchedGrid').html('<div class="col-12 text-center text-secondary">불러오기 실패</div>');
    });
}

/* ── 컬렉션 목록 로드 ── */
function hydrateWatchedCards() {
    $('img[data-needs-fetch="true"]').each(function() {
        if (this.dataset.fetched === 'true') return;

        this.dataset.fetched = 'true';

        var id = $(this).data('tmdb');
        var imgEl = this;

        fetch(ctp + '/movie/api/' + id)
            .then(function(r) {
                if (!r.ok) throw new Error('failed');
                return r.json();
            })
            .then(function(d) {
                if (d.posterPath) imgEl.src = TMDB_IMG + d.posterPath;

                var titleEl = document.getElementById('wt-' + id);
                if (titleEl && d.title) titleEl.textContent = d.title;
            })
            .catch(function() {});
    });
}

function loadCollections() {
    if (colLoaded) return;
    colLoaded = true;
    $.get(ctp + '/collection/my', function(list) {
        if (!list || list.length === 0) {
            $('#collectionTabCount').text(0);
            $('#collectionGrid').html(
                '<div class="col-12"><div class="empty-box">' +
                '<i class="fa fa-folder fa-3x mb-3"></i>' +
                '<p class="empty-text">컬렉션이 없습니다.</p>' +
                '</div></div>'
            );
            return;
        }
        $('#collectionTabCount').text(list.length);
        var html = '';
        list.forEach(function(c) {
            c.description = escapeHtml(c.description || '?ㅻ챸 ?놁쓬');
            html += '<div class="col-12 col-md-6 col-lg-4">';
            html += '<div class="col-card" onclick="location.href=\'' + ctp + '/collection/detail/' + c.collectionId + '\'">';
            html += '<div class="d-flex justify-content-between align-items-start mb-1">';
            html += '<div class="col-title">' + escapeHtml(c.title) + '</div>';
            html += '<span class="' + (c.isPublic == 1 ? 'badge-pub' : 'badge-pri') + '">';
            html += (c.isPublic == 1 ? '공개' : '비공개') + '</span>';
            html += '</div>';
            html += '<div class="col-desc">' + (c.description || '설명 없음') + '</div>';
            html += '<div class="col-meta">🎬 ' + c.movieCount + '편</div>';
            html += '</div></div>';
        });
        $('#collectionGrid').html(html);
    }, 'json').fail(function() {
        $('#collectionGrid').html('<div class="col-12 text-center text-secondary">불러오기 실패</div>');
    });
}

/* ── 컬렉션 생성 모달 ── */
function openCreateModal() {
    new bootstrap.Modal(document.getElementById('createColModal')).show();
}

function createCollection() {
    var title    = $('#colTitle').val().trim();
    var desc     = $('#colDesc').val().trim();
    var isPublic = $('#colPublic').is(':checked') ? 1 : 0;
    if (!title) { alert('제목을 입력해주세요.'); return; }
    $.post(ctp + '/collection/create',
        { title: title, description: desc, isPublic: isPublic },
        function(res) {
            if (res.status === 'ok') {
                bootstrap.Modal.getInstance(document.getElementById('createColModal')).hide();
                colLoaded = false;
                loadCollections();
            }
        }, 'json');
}

$(function() {
    ensureWithdrawAction();

    $('#withdrawForm').on('submit', function(e) {
        if (withdrawPasswordRequired) {
            var currentPw = $('#withdrawCurrentPw').val().trim();
            if (!currentPw) {
                alert('회원 탈퇴를 위해 현재 비밀번호를 입력해주세요.');
                e.preventDefault();
                return;
            }
        }

        if (!confirm('정말 회원 탈퇴하시겠습니까? 복구가 어렵습니다.')) {
            e.preventDefault();
        }
    });

    $('#withdrawModal').on('hidden.bs.modal', function() {
        $('#withdrawCurrentPw').val('');
    });
});

hydrateWatchedCards();
</script>
</body>
</html>
