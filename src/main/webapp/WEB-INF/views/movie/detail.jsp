<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<c:set var="backListUrl" value="${ctp}/movie/list"/>
<c:set var="backListLabel" value="영화 목록"/>
<c:if test="${not empty param.country}">
  <c:set var="backListUrl" value="${backListUrl}?country=${param.country}"/>
</c:if>
<c:if test="${param.from == 'animation'}">
  <c:set var="backListUrl" value="${ctp}/movie/animation"/>
  <c:if test="${not empty param.country}">
    <c:set var="backListUrl" value="${backListUrl}?country=${param.country}"/>
  </c:if>
  <c:set var="backListLabel" value="애니 목록"/>
</c:if>
<c:if test="${param.from == 'all'}">
  <c:set var="backListUrl" value="${ctp}/movie/all"/>
  <c:if test="${not empty param.country}">
    <c:set var="backListUrl" value="${backListUrl}?country=${param.country}"/>
  </c:if>
  <c:set var="backListLabel" value="전체 목록"/>
</c:if>
<c:if test="${param.from == 'home'}">
  <c:set var="backListUrl" value="${ctp}/"/>
  <c:set var="backListLabel" value="홈"/>
</c:if>
<c:if test="${param.from == 'trending'}">
  <c:url var="backListUrl" value="/movie/trending">
    <c:param name="timeWindow" value="${empty param.timeWindow ? 'week' : param.timeWindow}"/>
  </c:url>
  <c:set var="backListLabel" value="트렌딩"/>
</c:if>
<c:if test="${param.from == 'upcoming'}">
  <c:set var="backListUrl" value="${ctp}/movie/upcoming"/>
  <c:set var="backListLabel" value="개봉 예정"/>
</c:if>
<c:if test="${param.from == 'search'}">
  <c:url var="backListUrl" value="/movie/search">
    <c:param name="q" value="${param.q}"/>
    <c:param name="page" value="${empty param.page ? 1 : param.page}"/>
    <c:param name="mediaType" value="${empty param.mediaType ? 'all' : param.mediaType}"/>
    <c:param name="country" value="${empty param.country ? 'ALL' : param.country}"/>
  </c:url>
  <c:set var="backListLabel" value="검색 결과"/>
</c:if>
<c:if test="${param.from == 'genre' and not empty param.genreId}">
  <c:set var="backListUrl" value="${ctp}/movie/genre?genreId=${param.genreId}&genreName=${param.genreName}&page=${empty param.page ? 1 : param.page}"/>
  <c:set var="backListLabel" value="장르 목록"/>
</c:if>
<c:if test="${param.from != 'genre' and param.from != 'search' and not empty param.page}">
  <c:set var="backListUrl" value="${backListUrl}${fn:contains(backListUrl, '?') ? '&' : '?'}page=${param.page}"/>
</c:if>
<c:if test="${param.from != 'genre' and param.from != 'search' and not empty param.tab}">
  <c:set var="backListUrl" value="${backListUrl}${fn:contains(backListUrl, '?') ? '&' : '?'}tab=${param.tab}"/>
</c:if>
<c:set var="detailSearchMediaType" value="${movie.animation or param.from == 'animation' ? 'animation' : 'movie'}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${movie.title} - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    :root {
      --sg-bg: #121212;
      --sg-surface: rgba(255,255,255,0.06);
      --sg-surface-2: rgba(255,255,255,0.09);
      --sg-border: rgba(255,255,255,0.12);
      --sg-text-muted: #b8b8b8;
      --sg-green: #28a745;
      --sg-green-soft: rgba(40,167,69,0.16);
      --sg-yellow: #ffc107;
      --sg-danger-soft: rgba(220,53,69,0.14);
      --sg-shadow: 0 18px 40px rgba(0,0,0,0.35);
      --sg-radius-xl: 24px;
      --sg-radius-lg: 18px;
      --sg-radius-md: 14px;
    }

    body.bg-dark {
      background:
        radial-gradient(circle at top right, rgba(40,167,69,0.12), transparent 25%),
        radial-gradient(circle at top left, rgba(255,193,7,0.08), transparent 20%),
        var(--sg-bg) !important;
      color: #fff;
    }

    .detail-page {
      min-height: 100vh;
    }

    .backdrop {
      position: relative;
      min-height: 520px;
      background:
        linear-gradient(180deg, rgba(10,10,10,0.20) 0%, rgba(10,10,10,0.72) 55%, #121212 100%),
        url('https://image.tmdb.org/t/p/original${movie.backdropPath}') center/cover no-repeat;
      overflow: hidden;
    }

    .backdrop::before {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(90deg, rgba(0,0,0,0.72) 0%, rgba(0,0,0,0.35) 45%, rgba(0,0,0,0.7) 100%);
    }

    .hero-content {
      position: relative;
      z-index: 2;
      padding-top: 80px;
      padding-bottom: 40px;
    }

    .poster-wrap {
      position: relative;
      display: inline-block;
    }

    .poster-img {
      width: 100%;
      max-width: 290px;
      border-radius: 22px;
      box-shadow: 0 20px 48px rgba(0,0,0,0.45);
      border: 1px solid rgba(255,255,255,0.10);
      background: #1d1d1d;
    }

    .poster-wrap::after {
      content: '';
      position: absolute;
      inset: auto 18px -16px 18px;
      height: 24px;
      background: rgba(0,0,0,0.45);
      filter: blur(16px);
      z-index: -1;
      border-radius: 50%;
    }

    .movie-badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 14px;
      border-radius: 999px;
      background: rgba(255,255,255,0.08);
      border: 1px solid rgba(255,255,255,0.12);
      color: #f8f9fa;
      font-size: 0.9rem;
      margin-bottom: 14px;
      backdrop-filter: blur(10px);
    }

    .movie-title {
      font-size: clamp(2rem, 4vw, 3.3rem);
      font-weight: 800;
      letter-spacing: -0.03em;
      line-height: 1.08;
      margin-bottom: 12px;
    }

    .movie-subtitle {
      color: rgba(255,255,255,0.72);
      font-size: 1rem;
      margin-bottom: 18px;
    }

    .hero-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      margin-bottom: 24px;
    }

    .meta-pill {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 10px 14px;
      border-radius: 999px;
      background: rgba(255,255,255,0.08);
      border: 1px solid rgba(255,255,255,0.10);
      color: #fff;
      font-size: 0.95rem;
      backdrop-filter: blur(10px);
    }

    .meta-pill .label {
      color: rgba(255,255,255,0.62);
    }

    .action-group .btn {
      min-width: 132px;
      border-radius: 999px;
      padding: 11px 18px;
      font-weight: 600;
      box-shadow: 0 8px 20px rgba(0,0,0,0.15);
    }

    .section-shell {
      margin-top: -52px;
      position: relative;
      z-index: 5;
    }

    .content-card,
    .info-card,
    .review-card,
    .empty-card {
      background: linear-gradient(180deg, rgba(255,255,255,0.065), rgba(255,255,255,0.045));
      border: 1px solid var(--sg-border);
      border-radius: var(--sg-radius-xl);
      box-shadow: var(--sg-shadow);
      backdrop-filter: blur(12px);
    }

    .content-card {
      padding: 28px;
    }

    .info-card {
      padding: 24px;
      position: sticky;
      top: 24px;
    }

    .section-title {
      display: flex;
      align-items: center;
      gap: 12px;
      font-size: 1.18rem;
      font-weight: 700;
      margin-bottom: 18px;
    }

    .section-title::before {
      content: '';
      width: 6px;
      height: 24px;
      border-radius: 999px;
      background: linear-gradient(180deg, #34d058, #28a745);
      display: inline-block;
    }

    .overview-box {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: var(--sg-radius-lg);
      padding: 22px 22px;
      color: #e9ecef;
      line-height: 1.9;
    }

    .muted-text,
    .text-secondary {
      color: var(--sg-text-muted) !important;
    }

    .review-card {
      padding: 24px;
      border-radius: 22px;
      margin-bottom: 20px;
      transition: transform 0.18s ease, box-shadow 0.18s ease;
    }

    .review-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 20px 45px rgba(0,0,0,0.28);
    }

    .my-review-top {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 12px;
      margin-bottom: 16px;
    }

    .star-rating {
      display: flex;
      gap: 6px;
      font-size: 30px;
      cursor: pointer;
      user-select: none;
    }

    .star-rating span {
      color: #555;
      transition: transform 0.12s ease, color 0.12s ease;
    }

    .star-rating span:hover {
      transform: scale(1.08);
    }

    .spoiler-badge {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      background: rgba(255,193,7,0.14);
      color: #ffd95a;
      border: 1px solid rgba(255,193,7,0.24);
      border-radius: 999px;
      padding: 6px 12px;
      font-size: 0.8rem;
      font-weight: 600;
    }

    .review-body.blind-review {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 12px 14px;
      border-radius: 16px;
      background: rgba(244,63,94,0.12);
      border: 1px solid rgba(244,63,94,0.28);
      color: #fecdd3;
      font-weight: 700;
    }

    .form-label {
      font-weight: 600;
      color: #e9ecef !important;
      margin-bottom: 10px;
    }

    .form-control,
    .form-control:focus {
      background: rgba(255,255,255,0.06) !important;
      color: #fff !important;
      border: 1px solid rgba(255,255,255,0.10) !important;
      border-radius: 16px !important;
      box-shadow: none !important;
    }

    .form-control::placeholder {
      color: rgba(255,255,255,0.45);
    }

    .form-check-input {
      background-color: rgba(255,255,255,0.08);
      border-color: rgba(255,255,255,0.18);
    }

    .form-check-input:checked {
      background-color: var(--sg-green);
      border-color: var(--sg-green);
    }

    .empty-card,
    .login-alert {
      padding: 22px;
      border-radius: 18px;
    }

    .login-alert {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.09);
      color: #e9ecef;
    }

    .login-alert a {
      font-weight: 700;
      text-decoration: none;
    }

    .review-item {
      border-radius: 18px;
      background: rgba(255,255,255,0.045);
      border: 1px solid rgba(255,255,255,0.08);
      padding: 20px;
      margin-bottom: 16px;
    }

    .review-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
      margin-bottom: 12px;
    }

    .review-user {
      display: flex;
      align-items: center;
      flex-wrap: wrap;
      gap: 8px;
    }

    .avatar-circle {
      width: 38px;
      height: 38px;
      border-radius: 50%;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, rgba(40,167,69,0.8), rgba(52,208,88,0.55));
      color: #fff;
      font-weight: 700;
      font-size: 0.95rem;
      box-shadow: 0 10px 18px rgba(40,167,69,0.2);
    }

    .review-stars span {
      font-size: 0.95rem;
    }

    .review-body {
      color: #e9ecef;
      line-height: 1.8;
      margin-bottom: 14px;
      white-space: pre-wrap;
      word-break: break-word;
    }

    .review-actions {
      display: flex;
      justify-content: flex-end;
      margin-bottom: 12px;
    }

    .comment-area {
      border-top: 1px solid rgba(255,255,255,0.08);
      padding-top: 14px;
    }

    .comment-item {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 10px;
      padding: 10px 12px;
      border-radius: 14px;
      background: rgba(255,255,255,0.03);
      margin-bottom: 8px;
    }

    .comment-item.comment-reply {
      margin-left: 24px;
      padding-left: 16px;
      border-left: 2px solid rgba(255,255,255,0.10);
      background: rgba(255,255,255,0.02);
    }

    .comment-main {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      line-height: 1.6;
    }

    .comment-author {
      color: #6ee787;
      font-weight: 700;
      font-size: 0.87rem;
    }

    .comment-text {
      color: #d6d6d6;
      font-size: 0.9rem;
      word-break: break-word;
    }

    .comment-link {
      color: #aeb4ba;
      cursor: pointer;
      font-size: 0.82rem;
      text-decoration: none;
    }

    .comment-link:hover {
      color: #fff;
    }

    .comment-actions {
      display: flex;
      gap: 8px;
      flex-shrink: 0;
      align-items: center;
    }

    .reply-mark {
      color: #9ec5fe;
      font-size: 0.82rem;
      font-weight: 600;
    }

    .reply-box {
      margin: 8px 0 12px 24px;
      padding-left: 16px;
      border-left: 2px solid rgba(255,255,255,0.08);
    }

    .reply-editor {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .reply-editor .form-control {
      border-radius: 12px;
      background: rgba(255,255,255,0.06);
      color: #fff;
      border: 1px solid rgba(255,255,255,0.10);
    }

    .reply-editor .form-control::placeholder {
      color: rgba(255,255,255,0.5);
    }

    .reply-editor .btn {
      border-radius: 12px;
      white-space: nowrap;
    }

    .input-group.input-group-sm .form-control {
      border-radius: 14px 0 0 14px !important;
    }

    .input-group.input-group-sm .btn {
      border-radius: 0 14px 14px 0 !important;
    }

    @media (max-width: 576px) {
      .comment-item {
        flex-direction: column;
      }

      .comment-item.comment-reply,
      .reply-box {
        margin-left: 12px;
      }

      .comment-actions {
        width: 100%;
        justify-content: flex-end;
      }

      .reply-editor {
        flex-wrap: wrap;
      }

      .reply-editor .form-control {
        width: 100%;
      }
    }

    .info-title {
      font-size: 1.2rem;
      font-weight: 800;
      margin-bottom: 16px;
    }

    .info-table {
      width: 100%;
      margin: 0;
    }

    .info-table tr + tr td {
      border-top: 1px solid rgba(255,255,255,0.08);
    }

    .info-table td {
      padding: 13px 0;
      vertical-align: top;
    }

    .info-table td:first-child {
      width: 92px;
      color: var(--sg-text-muted);
      font-weight: 600;
    }

    .like-self {
      opacity: 0.72;
    }

    .btn-soft-secondary {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.10);
      color: #f8f9fa;
    }

    .btn-soft-secondary:hover {
      background: rgba(255,255,255,0.08);
      color: #fff;
    }

    .provider-list {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 16px;
    }

    .provider-badge {
      display: inline-flex;
      align-items: center;
      gap: 10px;
      padding: 10px 14px;
      border-radius: 16px;
      background: rgba(255,255,255,0.07);
      border: 1px solid rgba(255,255,255,0.10);
    }

    .provider-logo {
      width: 34px;
      height: 34px;
      border-radius: 10px;
      object-fit: cover;
      background: rgba(255,255,255,0.08);
    }

    .provider-type {
      color: var(--sg-text-muted);
      font-size: 0.8rem;
    }

    .keyword-cloud {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .keyword-chip {
      display: inline-flex;
      align-items: center;
      padding: 10px 14px;
      border-radius: 999px;
      background: rgba(40,167,69,0.12);
      border: 1px solid rgba(52,208,88,0.22);
      color: #d8ffe3;
      font-size: 0.9rem;
      line-height: 1;
      text-decoration: none;
      transition: transform 0.18s ease, border-color 0.18s ease, background 0.18s ease, color 0.18s ease;
    }

    .keyword-chip:hover {
      transform: translateY(-1px);
      border-color: rgba(52,208,88,0.46);
      background: rgba(40,167,69,0.2);
      color: #fff;
    }

    @media (max-width: 991px) {
      .section-shell {
        margin-top: -20px;
      }

      .info-card {
        position: static;
      }

      .hero-content {
        padding-top: 60px;
      }
    }

    @media (max-width: 767px) {
      .backdrop {
        min-height: auto;
      }

      .hero-content {
        padding-top: 42px;
        padding-bottom: 28px;
      }

      .poster-img {
        max-width: 220px;
      }

      .content-card,
      .info-card,
      .review-card {
        padding: 20px;
      }

      .movie-title {
        font-size: 2rem;
      }

      .my-review-top {
        flex-direction: column;
        align-items: stretch;
      }
    }
    
    .actor-card {
	  background: rgba(255,255,255,0.05);
	  border: 1px solid rgba(255,255,255,0.08);
	  border-radius: 16px;
	  overflow: hidden;
	  text-align: center;
	  padding-bottom: 12px;
	  transition: transform 0.18s;
	  cursor: pointer;
	}
	.actor-card:hover {
	  transform: translateY(-4px);
	}
  </style>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="detail-page">
  <!-- 영화 상세 헤더 -->
  <div class="backdrop">
    <div class="container hero-content">
      <div class="row align-items-end g-4">
        <div class="col-lg-auto text-center text-lg-start">
          <div class="poster-wrap">
            <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                 class="poster-img"
                 onerror="this.src='https://placehold.co/250x375?text=No+Image'">
          </div>
        </div>

        <div class="col-lg">
          <div class="movie-badge">
            <i class="fa fa-film"></i>
            <span>Movie Detail</span>
          </div>

          <h1 class="movie-title">${movie.title}</h1>
          <p class="movie-subtitle">${movie.originalTitle} · ${movie.releaseDate}</p>

          <div class="hero-meta">
            <div class="meta-pill">
              <i class="fa fa-star text-warning"></i>
              <span class="label">TMDB</span>
              <strong>${movie.voteAverage}</strong>
            </div>

            <c:if test="${movie.runtime > 0}">
              <div class="meta-pill">
                <i class="fa fa-clock-o"></i>
                <span class="label">상영시간</span>
                <strong>${movie.runtime}분</strong>
              </div>
            </c:if>
          </div>

          <c:if test="${not empty watchProviders}">
            <div class="provider-list">
              <c:forEach var="provider" items="${watchProviders}">
                <div class="provider-badge">
                  <img src="https://image.tmdb.org/t/p/w92${provider.logoPath}"
                       alt="${provider.providerName}"
                       class="provider-logo"
                       onerror="this.style.display='none'">
                  <div>
                    <div class="fw-bold small">${provider.providerName}</div>
                    <div class="provider-type">${provider.providerType}</div>
                  </div>
                </div>
              </c:forEach>
            </div>
            <div class="text-secondary small mt-2">KR 기준 OTT 정보, source: TMDB / JustWatch</div>
          </c:if>

          <div class="action-group d-flex flex-wrap gap-2">
			  <c:if test="${not empty sessionScope.loginUser}">
			    <button class="btn me-0 ${not empty myWatch ? 'btn-success' : 'btn-outline-success'}"
			            id="watchBtn" onclick="toggleWatchlist()">
			      <i class="fa fa-heart"></i>
			      ${not empty myWatch ? '찜 완료' : '보고싶어요'}
			    </button>
			    <c:if test="${not empty sessionScope.loginUser}">
				  <button class="btn btn-outline-info" id="watchedBtn"
				          onclick="toggleWatched()">
				    <i class="fa fa-eye"></i> <span id="watchedBtnText">봤어요</span>
				  </button>
				</c:if>
			    <%-- 컬렉션 추가 버튼 --%>
			    <button class="btn btn-outline-warning" id="collectionBtn" onclick="openCollectionModal()">
			      <i class="fa fa-folder-open"></i> <span id="collectionBtnText">컬렉션에 추가</span>
			    </button>
			  </c:if>
			  <a href="${backListUrl}" class="btn btn-soft-secondary">
			    <i class="fa fa-arrow-left me-1"></i> ${backListLabel}
			  </a>
			</div>
        </div>
      </div>
    </div>
  </div>

  <!-- 본문 -->
  <div class="container section-shell pb-5">
    <div class="row g-4">
      <div class="col-lg-8">
        <div class="content-card mb-4">
          <h4 class="section-title">줄거리</h4>
          <div class="overview-box">
            <c:choose>
              <c:when test="${not empty movie.overview}">
                ${movie.overview}
              </c:when>
              <c:otherwise>
                <span class="muted-text">등록된 줄거리가 없습니다.</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <c:if test="${not empty keywords}">
        <div class="content-card mb-4">
          <h4 class="section-title">키워드</h4>
          <div class="keyword-cloud">
            <c:forEach var="keyword" items="${keywords}">
              <c:url var="keywordSearchUrl" value="/movie/search">
                <c:param name="q" value="# ${keyword.name}"/>
                <c:param name="mediaType" value="${detailSearchMediaType}"/>
              </c:url>
              <a href="${keywordSearchUrl}" class="keyword-chip"># ${keyword.name}</a>
            </c:forEach>
          </div>
        </div>
        </c:if>

        <div class="content-card mb-4" id="ratingStatsBox" style="display:none;">
		  <h4 class="section-title">별점 분포</h4>
		  <div id="ratingStatsInner"></div>
		</div>
        
		<%-- 예고편 영역 --%>
		<c:if test="${not empty videos}">
		<div class="content-card mb-4">
		  <h4 class="section-title">예고편 / 영상</h4>
		  <div class="row g-3">
		    <c:forEach var="video" items="${videos}">
		    <div class="col-12 col-md-6">
		      <div style="position:relative;padding-bottom:56.25%;border-radius:16px;overflow:hidden;background:#000;">
		       <iframe
				  src="https://www.youtube.com/embed/${video.key}"
				  title="${video.name}"
				  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
				  allowfullscreen
				  referrerpolicy="strict-origin-when-cross-origin"
				  style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;">
				</iframe>
		      </div>
		      <p class="mt-2 mb-0 text-secondary small">${video.name}</p>
		    </div>
		    </c:forEach>
		  </div>
		</div>
		</c:if>
		
		<%-- 출연진 영역 --%>
		<c:if test="${not empty cast}">
			<div class="content-card mb-4">
			  <h4 class="section-title">출연진</h4>
			  <div class="row g-3">
			    <c:forEach var="actor" items="${cast}">
			    <div class="col-6 col-md-4 col-lg-3">
			      <div class="actor-card"
			           onclick="location.href='${ctp}/movie/person/${actor.id}'">
			        <c:choose>
			          <c:when test="${not empty actor['profile_path']}">
			            <img src="https://image.tmdb.org/t/p/w185${actor['profile_path']}"
			                 style="width:100%;height:180px;object-fit:cover;object-position:top;display:block;background:#1d1d1d;"
			                 onerror="this.src='https://placehold.co/185x180?text=No+Image'">
			          </c:when>
			          <c:otherwise>
			            <div style="width:100%;height:180px;background:#2a2a2a;display:flex;align-items:center;justify-content:center;">
			              <i class="fa fa-user" style="font-size:48px;color:#555;"></i>
			            </div>
			          </c:otherwise>
			        </c:choose>
			        <div style="padding:10px 8px 0;">
			          <div style="font-weight:700;font-size:0.92rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${actor['name']}</div>
			          <div style="font-size:0.82rem;color:#999;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${actor['character']}</div>
			        </div>
			      </div>
			    </div>
			    </c:forEach>
			  </div>
			</div>
			</c:if>
		
		<%-- 스태프 영역 --%>
		<c:if test="${not empty crew}">
		<div class="content-card mb-4">
		  <h4 class="section-title">스태프</h4>
		  <div class="row g-3">
		    <c:forEach var="staff" items="${crew}">
		    <div class="col-6 col-md-4">
		      <div style="display:flex;align-items:center;gap:12px;background:rgba(255,255,255,0.04);border:1px solid rgba(255,255,255,0.08);border-radius:14px;padding:12px;">
		        <c:choose>
		          <c:when test="${not empty staff.profile_path}">
		            <img src="https://image.tmdb.org/t/p/w185${staff.profile_path}"
		                 style="width:52px;height:52px;border-radius:50%;object-fit:cover;object-position:top;background:#1d1d1d;flex-shrink:0;"
		                 onerror="this.style.display='none'">
		          </c:when>
		          <c:otherwise>
		            <div style="width:52px;height:52px;border-radius:50%;background:#2a2a2a;display:flex;align-items:center;justify-content:center;flex-shrink:0;">
		              <i class="fa fa-user" style="color:#555;"></i>
		            </div>
		          </c:otherwise>
		        </c:choose>
		        <div style="overflow:hidden;">
		          <div style="font-weight:700;font-size:0.92rem;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${staff.name}</div>
		          <div style="font-size:0.82rem;color:#28a745;">${staff.job}</div>
		        </div>
		      </div>
		    </div>
		    </c:forEach>
		  </div>
		</div>
		</c:if>
        <div class="content-card mb-4">
          <h4 class="section-title">내 리뷰</h4>

          <c:choose>
            <c:when test="${not empty sessionScope.loginUser}">
              <c:choose>

                <%-- 이미 리뷰를 작성한 경우 --%>
                <c:when test="${not empty myReview}">
                  <div class="review-card mb-4" id="myReviewBox">
                    <div class="my-review-top">
                      <div>
                        <div class="d-flex align-items-center flex-wrap gap-2 mb-2">
                          <strong class="fs-5">내가 남긴 평점</strong>
                          <span class="text-warning fw-bold">${myReview.rating}점</span>
                        </div>

                        <div class="d-flex align-items-center flex-wrap gap-1 mb-2">
                          <c:forEach begin="1" end="5" var="i">
                            <c:choose>
                              <c:when test="${i <= myReview.rating}">
                                <span class="text-warning fs-5">★</span>
                              </c:when>
                              <c:otherwise>
                                <span class="text-secondary fs-5">☆</span>
                              </c:otherwise>
                            </c:choose>
                          </c:forEach>
                        </div>

                        <c:if test="${myReview.spoiler == 1}">
                          <div class="spoiler-badge mt-2">
                            <i class="fa fa-exclamation-triangle"></i> 스포일러 포함
                          </div>
                        </c:if>
                      </div>

                      <div class="d-flex gap-2">
                        <button class="btn btn-outline-warning btn-sm"
                                onclick="showEditForm()">수정</button>
                        <button class="btn btn-outline-danger btn-sm"
                                onclick="deleteReview(${myReview.reviewNo})">삭제</button>
                      </div>
                    </div>

                    <div class="review-body mb-0">${fn:escapeXml(myReview.content)}</div>
                  </div>

                  <!-- 리뷰 수정 폼 -->
                  <div class="review-card mb-4" id="editForm" style="display:none;">
                    <div class="mb-3">
                      <label class="form-label">별점 수정</label>
                      <div class="star-rating" id="editStarRating">
                        <span data-val="1" onclick="setEditRating(1)">★</span>
                        <span data-val="2" onclick="setEditRating(2)">★</span>
                        <span data-val="3" onclick="setEditRating(3)">★</span>
                        <span data-val="4" onclick="setEditRating(4)">★</span>
                        <span data-val="5" onclick="setEditRating(5)">★</span>
                      </div>
                      <input type="hidden" id="editRating" value="${myReview.rating}">
                    </div>

                    <div class="mb-3">
                      <label class="form-label">리뷰 내용 수정</label>
                      <textarea class="form-control"
                                id="editContent" rows="5">${fn:escapeXml(myReview.content)}</textarea>
                    </div>

                    <div class="form-check mb-4">
                      <input class="form-check-input" type="checkbox" id="editSpoiler"
                             ${myReview.spoiler == 1 ? 'checked' : ''}>
                      <label class="form-check-label text-secondary">스포일러 포함</label>
                    </div>

                    <div class="d-flex flex-wrap gap-2">
                      <button class="btn btn-warning"
                              onclick="updateReview(${myReview.reviewNo})">수정 완료</button>
                      <button class="btn btn-outline-secondary"
                              onclick="hideEditForm()">취소</button>
                    </div>
                  </div>
                </c:when>

                <%-- 아직 리뷰를 작성하지 않은 경우 --%>
                <c:otherwise>
                  <div class="review-card mb-4">
                    <div class="mb-3">
                      <label class="form-label">별점</label>
                      <div class="star-rating" id="starRating">
                        <span data-val="1" onclick="setRating(1)">★</span>
                        <span data-val="2" onclick="setRating(2)">★</span>
                        <span data-val="3" onclick="setRating(3)">★</span>
                        <span data-val="4" onclick="setRating(4)">★</span>
                        <span data-val="5" onclick="setRating(5)">★</span>
                      </div>
                      <small id="ratingText" class="text-warning d-inline-block mt-2"></small>
                      <input type="hidden" id="rating" value="0">
                    </div>

                    <div class="mb-3">
                      <label class="form-label">리뷰 내용</label>
                      <textarea class="form-control"
                                id="content" rows="5"
                                placeholder="이 영화에 대한 리뷰를 작성해주세요."></textarea>
                    </div>
					<div class="d-flex justify-content-between align-items-center mt-1">
					  <small id="contentMsg" class="text-danger"></small>
					  <small id="contentCount" class="text-secondary">0 / 2000</small>
					</div>
                    <div class="form-check mb-4">
                      <input class="form-check-input" type="checkbox" id="spoiler">
                      <label class="form-check-label text-secondary">스포일러 포함</label>
                    </div>

                    <button class="btn btn-success px-4" onclick="submitReview()">리뷰 등록</button>
                  </div>
                </c:otherwise>

              </c:choose>
            </c:when>

            <c:otherwise>
              <div class="login-alert mb-0">
                <a href="${ctp}/user/login" class="text-success">로그인</a> 후 리뷰를 작성할 수 있습니다.
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="content-card">
		  <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
		    <h4 class="section-title mb-0">리뷰</h4>
		    <div class="d-flex gap-2">
		      <button class="btn btn-sm sort-btn active" onclick="sortReviews('latest', this)"
		              style="border-radius:999px;font-size:12px;font-weight:700;background:#28a745;color:#fff;border:none;">최신순</button>
		      <button class="btn btn-sm sort-btn" onclick="sortReviews('rating_high', this)"
		              style="border-radius:999px;font-size:12px;font-weight:700;background:rgba(255,255,255,0.08);color:#aaa;border:1px solid rgba(255,255,255,0.15);">평점 높은순</button>
		      <button class="btn btn-sm sort-btn" onclick="sortReviews('rating_low', this)"
		              style="border-radius:999px;font-size:12px;font-weight:700;background:rgba(255,255,255,0.08);color:#aaa;border:1px solid rgba(255,255,255,0.15);">평점 낮은순</button>
		      <button class="btn btn-sm sort-btn" onclick="sortReviews('likes', this)"
		              style="border-radius:999px;font-size:12px;font-weight:700;background:rgba(255,255,255,0.08);color:#aaa;border:1px solid rgba(255,255,255,0.15);">공감순</button>
		    </div>
		  </div>

          <div id="reviewList">
            <div class="empty-card">
              <p class="text-secondary mb-0">아직 작성된 리뷰가 없습니다.</p>
            </div>
          </div>
        </div>
      </div>
		<div class="content-card mb-4" id="similarBox" style="display:none;">
		  <h4 class="section-title">비슷한 영화</h4>
		  <div class="row g-3" id="similarList"></div>
		</div>
      <!-- 오른쪽 정보 영역 -->
      <div class="col-lg-4">
        <div class="info-card">
          <div class="info-title">영화 정보</div>
          <table class="info-table">
            <tr>
              <td>제목</td>
              <td>${movie.title}</td>
            </tr>
            <tr>
              <td>원제</td>
              <td>${movie.originalTitle}</td>
            </tr>
            <tr>
              <td>개봉일</td>
              <td>${movie.releaseDate}</td>
            </tr>
            <tr>
              <td>상영시간</td>
              <td>
                <c:choose>
                  <c:when test="${movie.runtime > 0}">${movie.runtime}분</c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
            </tr>
            <tr>
              <td>TMDB 평점</td>
              <td class="text-warning fw-bold">★ ${movie.voteAverage}</td>
            </tr>
            <tr>
              <td>OTT</td>
              <td>
                <c:choose>
                  <c:when test="${not empty watchProviders}">
                    <c:forEach var="provider" items="${watchProviders}" varStatus="st">
                      ${provider.providerName}<c:if test="${not st.last}">, </c:if>
                    </c:forEach>
                  </c:when>
                  <c:otherwise>-</c:otherwise>
                </c:choose>
              </td>
            </tr>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>
<%-- 컬렉션 추가 모달 --%>
<c:if test="${not empty sessionScope.loginUser}">
<div class="modal fade" id="collectionModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content" style="background:#1e1e1e;color:#fff;border:1px solid rgba(255,255,255,0.12);">
      <div class="modal-header" style="border-color:rgba(255,255,255,0.1);">
        <h5 class="modal-title">컬렉션에 추가</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body" id="collectionModalBody">
        <div class="text-center py-3 text-secondary">불러오는 중..</div>
      </div>
      <div class="modal-footer" style="border-color:rgba(255,255,255,0.1);">
        <a href="${ctp}/collection/list" class="btn btn-outline-secondary btn-sm">
          컬렉션 관리
        </a>
        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">닫기</button>
      </div>
    </div>
  </div>
</div>
</c:if>
<c:if test="${not empty sessionScope.loginUser}">
<div class="modal fade" id="reportModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content" style="background:#1e1e1e;color:#fff;border:1px solid rgba(255,255,255,0.12);">
      <div class="modal-header" style="border-color:rgba(255,255,255,0.1);">
        <h5 class="modal-title">리뷰 신고</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="reportTargetId">
        <div class="mb-3">
          <label class="form-label">신고 사유</label>
          <textarea id="reportReason" class="form-control"
                    style="background:rgba(255,255,255,0.06);color:#fff;border:1px solid rgba(255,255,255,0.1);"
                    rows="3" placeholder="신고 사유를 입력해주세요 (500자 이하)" maxlength="500"></textarea>
        </div>
      </div>
      <div class="modal-footer" style="border-color:rgba(255,255,255,0.1);">
        <button class="btn btn-secondary btn-sm" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-danger btn-sm" onclick="submitReport()">신고하기</button>
      </div>
    </div>
  </div>
</div>
</c:if>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
var currentRating = 0;
var editRating = ${not empty myReview ? myReview.rating : 0};
var tmdbId = ${movie.tmdbId};
var ctp = '${ctp}';
var loginUserNo = ${not empty sessionScope.loginUser ? sessionScope.loginUser.userNo : 0};
var isAdmin = ${not empty sessionScope.loginUser and sessionScope.loginUser.userRole eq 'ADMIN'};
var currentSort = 'latest';

function currentReturnUrl() {
    var path = window.location.pathname;
    if (ctp && path.indexOf(ctp) === 0) {
        path = path.substring(ctp.length) || '/';
    }
    return path + window.location.search + window.location.hash;
}

function goLogin() {
    location.href = ctp + '/user/login?redirect=' + encodeURIComponent(currentReturnUrl());
}

function escapeHtml(value) {
    return $('<div>').text(value == null ? '' : String(value)).html();
}

$(document).ready(function() {
    loadReviews();
    setEditRating(editRating);
    refreshCollectionState();

    // 리뷰 textarea 실시간 길이 체크
    $('#content').on('input', function() {
        var len = $(this).val().trim().length;
        $('#contentCount').text(len + ' / 2000');
        if (len === 0) {
            $('#contentMsg').text('');
        } else if (len < 10) {
            $('#contentMsg').html('<span class="text-danger">10자 이상 입력해주세요. (' + len + '/10)</span>');
        } else if (len > 2000) {
            $('#contentMsg').html('<span class="text-danger">2000자를 초과했습니다.</span>');
        } else {
            $('#contentMsg').html('<span class="text-success">작성 가능합니다.</span>');
        }
    });

    // 봤어요 초기 상태 확인
    $.get(ctp + '/movie/watched/check', { movieNo: tmdbId }, function(res) {
        if (res.watched) {
            $('#watchedBtn').removeClass('btn-outline-info').addClass('btn-info');
                $('#watchedBtnText').text('봤어요 ✓');
        }
    }, 'json');

    // 별점 분포 로드
   $.get(ctp + '/review/stats', { movieNo: tmdbId }, function(list) {
	    if (!list || list.length === 0) return;
	    var data = list[0];
	    if (!data) return;
        var stars = ['star5','star4','star3','star2','star1'];
        var labels = ['5점','4점','3점','2점','1점'];
        var total = 0;
        stars.forEach(function(k) { total += (data[k] || 0); });
        if (total === 0) return;
        var html = '';
        stars.forEach(function(k, i) {
            var cnt = data[k] || 0;
            var pct = total > 0 ? Math.round(cnt / total * 100) : 0;
            html += '<div class="d-flex align-items-center gap-2 mb-2">';
            html += '<span style="font-size:13px;color:#ffc107;min-width:28px;">' + labels[i] + '</span>';
            html += '<div class="flex-grow-1" style="background:rgba(255,255,255,0.08);border-radius:999px;height:8px;">';
            html += '<div style="width:' + pct + '%;background:#ffc107;height:8px;border-radius:999px;transition:width .4s;"></div>';
            html += '</div>';
            html += '<span style="font-size:12px;color:#aaa;min-width:40px;text-align:right;">' + cnt + '명</span>';
            html += '</div>';
        });
        $('#ratingStatsInner').html(html);
        $('#ratingStatsBox').show();
    }, 'json');

    // 비슷한 영화 로드
    $.get(ctp + '/movie/similar', { tmdbId: tmdbId, page: 1 }, function(list) {
        if (!list || list.length === 0) return;
        var show = list.slice(0, 6);
        var html = '';
        show.forEach(function(m) {
            if (!m.posterPath) return;
            html += '<div class="col-6 col-md-4 col-lg-2">';
            html += '<div style="cursor:pointer;border-radius:12px;overflow:hidden;';
            html += 'background:rgba(255,255,255,0.05);transition:transform .2s;"';
            html += ' onclick="location.href=\'' + ctp + '/movie/detail/' + m.tmdbId + '\'"';
            html += ' onmouseover="this.style.transform=\'translateY(-4px)\'"';
            html += ' onmouseout="this.style.transform=\'\'">';
            html += '<img src="https://image.tmdb.org/t/p/w300' + m.posterPath + '"';
            html += ' style="width:100%;aspect-ratio:2/3;object-fit:cover;"';
            html += ' onerror="this.style.display=\'none\'">';
            html += '<div style="padding:8px;font-size:12px;font-weight:700;';
            html += 'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + m.title + '</div>';
            html += '</div></div>';
        });
        if (html) {
            $('#similarList').html(html);
            $('#similarBox').show();
        }
    }, 'json');

});

/* 별점 선택 */
function setRating(val) {
    currentRating = val;
    $('#rating').val(val);
    $('#ratingText').text(val + '점');
    $('#starRating span').each(function() {
        $(this).css('color', $(this).data('val') <= val ? '#ffc107' : '#555');
    });
}

$('#starRating span').hover(
    function() {
        var val = $(this).data('val');
        $('#starRating span').each(function() {
            $(this).css('color', $(this).data('val') <= val ? '#ffc107' : '#555');
        });
    },
    function() {
        $('#starRating span').each(function() {
            $(this).css('color', $(this).data('val') <= currentRating ? '#ffc107' : '#555');
        });
    }
);

function setEditRating(val) {
    editRating = val;
    $('#editRating').val(val);
    $('#editStarRating span').each(function() {
        $(this).css('color', $(this).data('val') <= val ? '#ffc107' : '#555');
    });
}

function showEditForm() { $('#myReviewBox').hide(); $('#editForm').show(); }
function hideEditForm()  { $('#editForm').hide();   $('#myReviewBox').show(); }

/* 리뷰 등록 */
function submitReview() {
    var rating  = $('#rating').val();
    var content = $('#content').val();
    var spoiler = $('#spoiler').is(':checked') ? 1 : 0;

    if (rating == 0) {
        Swal.fire({ icon: 'warning', title: '별점 필요', text: '별점을 선택해주세요.' });
        return;
    }
    if (content.trim().length < 10) {
        Swal.fire({ icon: 'warning', title: '내용 부족', text: '리뷰 내용은 10자 이상 입력해주세요.' });
        return;
    }
    if (content.trim().length > 2000) {
        Swal.fire({ icon: 'warning', title: '내용 초과', text: '리뷰 내용은 2000자 이하로 작성해주세요.' });
        return;
    }

    $.ajax({
        url: ctp + '/review/write', type: 'POST',
        data: { movieNo: tmdbId, rating: rating, content: content, spoiler: spoiler },
        success: function(res) {
            if (res == 'ok') {
                Swal.fire({ icon: 'success', title: '등록 완료', text: '리뷰가 등록되었습니다.', timer: 1500, showConfirmButton: false })
                    .then(() => location.reload());
            } else if (res == 'dup') {
                Swal.fire({ icon: 'info', title: '이미 작성한 리뷰', text: '이 영화에는 이미 리뷰를 작성했습니다. 기존 리뷰를 수정해주세요.' });
            } else if (res == 'length') {
                Swal.fire({ icon: 'warning', title: '내용 길이 오류', text: '리뷰 내용은 10자 이상 2000자 이하로 작성해주세요.' });
            } else if (res == 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                    .then(() => goLogin());
            } else {
                Swal.fire({ icon: 'error', title: '등록 실패', text: '리뷰 등록에 실패했습니다.' });
            }
        }
    });
}

/* 리뷰 수정 */
function updateReview(reviewNo) {
    var rating  = $('#editRating').val();
    var content = $('#editContent').val();
    var spoiler = $('#editSpoiler').is(':checked') ? 1 : 0;

    if (!content.trim()) {
        Swal.fire({ icon: 'warning', title: '내용 필요', text: '리뷰 내용을 입력해주세요.' });
        return;
    }
    if (content.trim().length < 10) {
        Swal.fire({ icon: 'warning', title: '내용 부족', text: '리뷰 내용은 10자 이상 입력해주세요.' });
        return;
    }
    if (content.trim().length > 2000) {
        Swal.fire({ icon: 'warning', title: '내용 초과', text: '리뷰 내용은 2000자 이하로 작성해주세요.' });
        return;
    }

    $.ajax({
        url: ctp + '/review/update', type: 'POST',
        data: { reviewNo: reviewNo, rating: rating, content: content, spoiler: spoiler },
        success: function(res) {
            if (res == 'ok') {
                Swal.fire({ icon: 'success', title: '수정 완료', text: '리뷰가 수정되었습니다.', timer: 1500, showConfirmButton: false })
                    .then(() => location.reload());
            } else if (res == 'auth') {
                Swal.fire({ icon: 'error', title: '권한 없음', text: '수정 권한이 없습니다.' });
            } else if (res == 'length') {
                Swal.fire({ icon: 'warning', title: '내용 길이 오류', text: '리뷰 내용은 10자 이상 2000자 이하로 작성해주세요.' });
            } else if (res == 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                    .then(() => goLogin());
            } else {
                Swal.fire({ icon: 'error', title: '수정 실패', text: '수정에 실패했습니다.' });
            }
        }
    });
}

/* 리뷰 삭제 */
function deleteReview(reviewNo) {
    Swal.fire({
        icon: 'warning', title: '리뷰 삭제',
        text: '리뷰를 삭제하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '삭제', cancelButtonText: '취소',
        confirmButtonColor: '#e50914'
    }).then(function(result) {
        if (!result.isConfirmed) return;
        $.ajax({
            url: ctp + '/review/delete', type: 'POST',
            data: { reviewNo: reviewNo },
            success: function(res) {
                if (res == 'ok') {
                    Swal.fire({ icon: 'success', title: '삭제 완료', timer: 1200, showConfirmButton: false })
                        .then(() => location.reload());
                } else if (res == 'auth') {
                    Swal.fire({ icon: 'error', title: '권한 없음', text: '삭제 권한이 없습니다.' });
                } else {
                    Swal.fire({ icon: 'error', title: '삭제 실패', text: '삭제에 실패했습니다.' });
                }
            }
        });
    });
}

/* 리뷰 목록 로드 */
function loadReviews() {
    $.ajax({
        url: ctp + '/review/list', type: 'GET',
        data: { movieNo: tmdbId },
        success: function(list) { renderReviews(list); }
    });
}

function sortReviews(sort, btn) {
    currentSort = sort;
    $('.sort-btn').removeClass('active')
        .css({
            background: 'rgba(255,255,255,0.08)',
            color: '#aaa',
            border: '1px solid rgba(255,255,255,0.15)'
        });
    $(btn).addClass('active')
        .css({
            background: '#28a745',
            color: '#fff',
            border: 'none'
        });

    $.ajax({
        url: ctp + '/review/list/sorted',
        type: 'GET',
        data: { movieNo: tmdbId, sort: sort },
        success: function(list) {
            renderReviews(list);
        },
        error: function() {
            Swal.fire({ icon: 'error', title: '정렬 실패', text: '리뷰 목록을 다시 불러오지 못했습니다.' });
        }
    });
}

/* 리뷰 렌더링 */
function renderReviews(list) {
    var blindReviewMessage = '\uC2E0\uACE0\uB85C \uC778\uD574 \uBE14\uB77C\uC778\uB4DC \uCC98\uB9AC\uB41C \uB9AC\uBDF0\uC785\uB2C8\uB2E4.';
    var html = '';
    var visibleList = (list || []).filter(function(r) {
        return loginUserNo == 0 || r.userNo != loginUserNo;
    });
    var reviewNos = [];

    if (visibleList.length == 0) {
        var emptyText = loginUserNo != 0 ? '다른 사용자가 남긴 리뷰가 아직 없습니다.' : '아직 작성된 리뷰가 없습니다.';
        html = '<div class="empty-card"><p class="text-secondary mb-0">' + emptyText + '</p></div>';
    } else {
        visibleList.forEach(function(r) {
            reviewNos.push(r.reviewNo);
            var stars = '';
            for (var i = 1; i <= 5; i++) {
                stars += i <= r.rating ? '<span class="text-warning">★</span>' : '<span class="text-secondary">☆</span>';
            }
            var userName = r.userName || '';
            var userInitial = userName ? userName.substring(0,1) : '?';
            html += '<div class="review-item">';
            html += '<div class="review-header">';
            html += '<div class="review-user">';
            html += '<div class="avatar-circle">' + escapeHtml(userInitial) + '</div>';
            html += '<div><div class="fw-bold">' + escapeHtml(userName) + '</div>';
            html += '<div class="review-stars">' + stars;
            html += '<span class="text-secondary small ms-2">' + r.rating + '점</span></div></div></div>';
            html += '<small class="text-secondary">' + escapeHtml(r.regDate || '') + '</small></div>';
            if (r.spoiler == 1) {
                html += '<div class="spoiler-badge mb-3"><i class="fa fa-exclamation-triangle"></i> 스포일러 포함</div>';
            }
            if (r.content === blindReviewMessage) {
                html += '<div class="review-body blind-review"><i class="fa fa-eye-slash"></i> 블라인드 처리된 리뷰</div>';
            } else {
                html += '<div class="review-body">' + escapeHtml(r.content) + '</div>';
            }
            html += '<div class="review-actions">';
            if (loginUserNo != 0 && r.userNo == loginUserNo) {
                html += '<button class="btn btn-outline-secondary btn-sm like-self" disabled>';
                html += '<i class="fa fa-thumbs-up"></i> <span class="like-cnt">' + r.likeCnt + '</span>';
                html += ' <small>(내 리뷰)</small></button>';
            } else {
                html += '<button class="btn btn-outline-secondary btn-sm" onclick="toggleLike(' + r.reviewNo + ', this)">';
                html += '<i class="fa fa-thumbs-up"></i> <span class="like-cnt">' + r.likeCnt + '</span></button>';
                if (loginUserNo != 0 && !isAdmin) {
                    html += '<button class="btn btn-outline-danger btn-sm ms-1" onclick="reportReview(' + r.reviewNo + ')">';
                    html += '<i class="fa fa-flag"></i></button>';
                }
                if (isAdmin) {
                    html += '<button class="btn btn-outline-danger btn-sm ms-1" onclick="deleteReview(' + r.reviewNo + ')">삭제</button>';
                }
            }
            html += '</div>';
            html += '<div class="comment-area"><div id="commentList-' + r.reviewNo + '" class="mb-2"></div>';
            if (loginUserNo != 0) {
                html += '<div class="input-group input-group-sm">';
                html += '<input type="text" class="form-control bg-secondary text-white border-0" id="commentInput-' + r.reviewNo + '" placeholder="댓글을 입력하세요.." maxlength="500">';
                html += '<button class="btn btn-outline-success btn-sm" onclick="writeComment(' + r.reviewNo + ')">등록</button></div>';
            }
            html += '</div></div>';
        });
    }
    $('#reviewList').html(html);
    reviewNos.forEach(function(reviewNo) {
        loadComments(reviewNo);
    });
}

/* 댓글 목록 로드 */
function renderCommentItem(c, isReply, reviewNo) {
    var html = '<div class="comment-item' + (isReply ? ' comment-reply' : '') + '" id="comment-' + c.commentNo + '">';
    html += '<div class="comment-main">';
    if (isReply && c.parentUserName) {
        html += '<span class="reply-mark">↳ @' + escapeHtml(c.parentUserName) + '</span>';
    }
    html += '<span class="comment-author">' + escapeHtml(c.userName) + '</span>';
    html += '<span class="comment-text" id="commentText-' + c.commentNo + '">' + escapeHtml(c.content) + '</span>';
    html += '</div><div class="comment-actions">';
    if (loginUserNo != 0 && !isReply) {
        html += '<span class="comment-link" onclick="toggleReplyBox(' + c.commentNo + ', ' + reviewNo + ')">답글</span>';
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

function renderReplyBox(parentCommentNo, reviewNo) {
    if (loginUserNo == 0) return '';

    var html = '<div class="reply-box" id="replyBox-' + parentCommentNo + '" style="display:none;">';
    html += '<div class="reply-editor">';
    html += '<input type="text" class="form-control form-control-sm" id="replyInput-' + parentCommentNo + '" placeholder="답글을 입력하세요.." maxlength="500">';
    html += '<button class="btn btn-outline-success btn-sm" onclick="writeReply(' + parentCommentNo + ', ' + reviewNo + ')">등록</button>';
    html += '<button class="btn btn-outline-secondary btn-sm" onclick="toggleReplyBox(' + parentCommentNo + ', ' + reviewNo + ')">닫기</button>';
    html += '</div></div>';
    return html;
}

function toggleReplyBox(parentCommentNo, reviewNo) {
    var $box = $('#replyBox-' + parentCommentNo);
    var isVisible = $box.is(':visible');
    $('#commentList-' + reviewNo + ' .reply-box').hide();
    if (isVisible) {
        return;
    }
    $box.show();
    $('#replyInput-' + parentCommentNo).focus();
}

function loadComments(reviewNo) {
    $.ajax({
        url: ctp + '/comment/list', type: 'GET',
        data: { reviewNo: reviewNo },
        success: function(list) {
            var tops = [];
            var repliesByParent = {};
            var html = '';

            list.forEach(function(c) {
                if (c.parentId == null) {
                    tops.push(c);
                }
                else {
                    if (!repliesByParent[c.parentId]) repliesByParent[c.parentId] = [];
                    repliesByParent[c.parentId].push(c);
                }
            });

            tops.forEach(function(c) {
                html += renderCommentItem(c, false, reviewNo);
                (repliesByParent[c.commentNo] || []).forEach(function(reply) {
                    html += renderCommentItem(reply, true, reviewNo);
                });
                html += renderReplyBox(c.commentNo, reviewNo);
            });

            $('#commentList-' + reviewNo).html(html);
        }
    });
}

/* 댓글 등록 */
function writeComment(reviewNo) {
    var content = $('#commentInput-' + reviewNo).val();
    if (!content.trim()) {
        Swal.fire({ icon: 'warning', title: '내용 필요', text: '댓글 내용을 입력해주세요.', timer: 1500, showConfirmButton: false });
        return;
    }
    $.ajax({
        url: ctp + '/comment/write', type: 'POST',
        data: { reviewNo: reviewNo, content: content },
        success: function(res) {
            if (res == 'ok') {
                $('#commentInput-' + reviewNo).val('');
                loadComments(reviewNo);
            } else if (res == 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                    .then(() => goLogin());
            } else {
                Swal.fire({ icon: 'error', title: '등록 실패', text: '댓글 등록에 실패했습니다.' });
            }
        }
    });
}

/* 답글 등록 */
function writeReply(parentCommentNo, reviewNo) {
    var content = $('#replyInput-' + parentCommentNo).val();
    if (!content.trim()) {
        Swal.fire({ icon: 'warning', title: '내용 필요', text: '답글 내용을 입력해주세요.', timer: 1500, showConfirmButton: false });
        return;
    }

    $.ajax({
        url: ctp + '/comment/write', type: 'POST',
        data: { reviewNo: reviewNo, parentId: parentCommentNo, content: content },
        success: function(res) {
            if (res == 'ok') {
                loadComments(reviewNo);
            } else if (res == 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                    .then(() => goLogin());
            } else {
                Swal.fire({ icon: 'error', title: '등록 실패', text: '답글 등록에 실패했습니다.' });
            }
        }
    });
}

/* 댓글 수정 */
function editComment(commentNo) {
    var current = $('#commentText-' + commentNo).text();
    Swal.fire({
        title: '댓글 수정', input: 'textarea',
        inputValue: current, inputPlaceholder: '댓글 내용을 입력하세요.',
        inputAttributes: { maxlength: 500 },
        showCancelButton: true,
        confirmButtonText: '수정', cancelButtonText: '취소',
        customClass: { input: 'bg-dark text-white' }
    }).then(function(result) {
        if (!result.isConfirmed || !result.value.trim()) return;
        $.ajax({
            url: ctp + '/comment/update', type: 'POST',
            data: { commentNo: commentNo, content: result.value },
            success: function(res) {
                if (res == 'ok') {
                    $('#commentText-' + commentNo).text(result.value);
                } else {
                    Swal.fire({ icon: 'error', title: '수정 실패', timer: 1200, showConfirmButton: false });
                }
            }
        });
    });
}

/* 댓글 삭제 */
function deleteComment(commentNo, reviewNo) {
    Swal.fire({
        icon: 'warning', title: '댓글 삭제', text: '댓글을 삭제하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '삭제', cancelButtonText: '취소',
        confirmButtonColor: '#e50914'
    }).then(function(result) {
        if (!result.isConfirmed) return;
        $.ajax({
            url: ctp + '/comment/delete', type: 'POST',
            data: { commentNo: commentNo },
            success: function(res) {
                if (res == 'ok') loadComments(reviewNo);
                else if (res == 'auth') Swal.fire({ icon: 'error', title: '권한 없음', text: '삭제 권한이 없습니다.' });
                else Swal.fire({ icon: 'error', title: '삭제 실패', timer: 1200, showConfirmButton: false });
            }
        });
    });
}

/* 찜하기 토글 */
function toggleWatchlist() {
    $.ajax({
        url: ctp + '/movie/watchlist', type: 'POST',
        data: { tmdbId: tmdbId },
        success: function(res) {
            if (res == 'ok') {
                $('#watchBtn').removeClass('btn-outline-success').addClass('btn-success')
                              .html('<i class="fa fa-heart"></i> 찜 완료');
            } else if (res == 'cancel') {
                $('#watchBtn').removeClass('btn-success').addClass('btn-outline-success')
                              .html('<i class="fa fa-heart"></i> 보고싶어요');
            } else if (res == 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                    .then(() => goLogin());
            }
        }
    });
}

/* 리뷰 공감 토글 */
function toggleLike(reviewNo, btn) {
    <c:choose>
        <c:when test="${not empty sessionScope.loginUser}">
        $.ajax({
            url: ctp + '/review/like', type: 'POST',
            data: { reviewNo: reviewNo },
            success: function(res) {
                if (res == 'ok') {
                    var cnt = parseInt($(btn).find('.like-cnt').text());
                    $(btn).find('.like-cnt').text(cnt + 1);
                    $(btn).removeClass('btn-outline-secondary').addClass('btn-warning');
                } else if (res == 'cancel') {
                    var cnt = parseInt($(btn).find('.like-cnt').text());
                    $(btn).find('.like-cnt').text(cnt - 1);
                    $(btn).removeClass('btn-warning').addClass('btn-outline-secondary');
                } else if (res == 'login') {
                    Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                        .then(() => goLogin());
                }
                if ((res == 'ok' || res == 'cancel') && currentSort === 'likes') {
                    sortReviews(currentSort, $('.sort-btn.active')[0]);
                }
            }
        });
        </c:when>
        <c:otherwise>
        Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
            .then(() => goLogin());
        </c:otherwise>
    </c:choose>
}

/* 컬렉션 모달 열기 */
function openCollectionModal() {
    var modal = new bootstrap.Modal(document.getElementById('collectionModal'));
    modal.show();
    loadCollectionModal();
}

/* 컬렉션 영화 추가/제거 */
function addToCollection(collectionId, btn) {
    $.post(ctp + '/collection/movie/toggle',
        { collectionId: collectionId, movieId: tmdbId },
        function(res) {
            if (res.status === 'added') {
                updateCollectionItemState(btn, true);
                updateCollectionButtonState(true);
            } else if (res.status === 'removed') {
                updateCollectionItemState(btn, false);
                syncCollectionButtonStateFromModal();
            } else if (res.status === 'fail') {
                Swal.fire({ icon: 'warning', title: '추가 실패', text: '유효한 영화만 컬렉션에 담을 수 있습니다.' });
            } else if (res.status === 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' });
            }
        }, 'json');
}

function refreshCollectionState() {
    if (!document.getElementById('collectionBtn')) return;
    $.get(ctp + '/collection/my', { movieId: tmdbId }, function(list) {
        renderCollectionModal(list);
        updateCollectionButtonState(hasAnyCollectionSelection(list));
    }, 'json');
}

function loadCollectionModal() {
    $.get(ctp + '/collection/my', { movieId: tmdbId }, function(list) {
        renderCollectionModal(list);
        updateCollectionButtonState(hasAnyCollectionSelection(list));
    }, 'json');
}

function renderCollectionModal(list) {
    if (!list || list.length === 0) {
        $('#collectionModalBody').html(
            '<p class="text-secondary text-center">컬렉션이 없습니다. ' +
            '<a href="' + ctp + '/collection/list" class="text-warning">만들러 가기</a></p>'
        );
        updateCollectionButtonState(false);
        return;
    }

    var html = '<div class="list-group">';
    list.forEach(function(c) {
        var activeClass = c.inCollection ? ' active border-warning' : '';
        var actionText = c.inCollection ? '컬렉션 삭제' : '컬렉션 추가';
        var checkText = c.inCollection ? '✓' : '';

        html += '<button class="list-group-item list-group-item-action bg-dark text-white border-secondary collection-item' + activeClass + '"';
        html += ' data-in-collection="' + (c.inCollection ? 'true' : 'false') + '"';
        html += ' onclick="addToCollection(' + c.collectionId + ', this)">';
        html += '<div class="d-flex justify-content-between align-items-center gap-2">';
        html += '<span>' + escapeHtml(c.title) + '</span>';
        html += '<div class="d-flex align-items-center gap-2">';
        html += '<span class="col-action badge text-bg-warning">' + actionText + '</span>';
        html += '<span class="col-check">' + checkText + '</span>';
        html += '</div></div>';
        html += '<small class="d-block text-secondary mt-1">' + (c.movieCount || 0) + '개 작품</small>';
        html += '</button>';
    });
    html += '</div>';
    $('#collectionModalBody').html(html);
}

function updateCollectionItemState(btn, selected) {
    var $btn = $(btn);
    $btn.attr('data-in-collection', selected ? 'true' : 'false')
        .toggleClass('active border-warning', selected);
    $btn.find('.col-action').text(selected ? '컬렉션 삭제' : '컬렉션 추가');
    $btn.find('.col-check').text(selected ? '✓' : '');
}

function hasAnyCollectionSelection(list) {
    if (!list || list.length === 0) return false;
    return list.some(function(c) {
        return c.inCollection == 1 || c.inCollection === true;
    });
}

function syncCollectionButtonStateFromModal() {
    var hasSelected = $('#collectionModalBody .collection-item[data-in-collection="true"]').length > 0;
    updateCollectionButtonState(hasSelected);
}

function updateCollectionButtonState(hasSelected) {
    var $btn = $('#collectionBtn');
    if (!$btn.length) return;

    $btn.toggleClass('btn-warning', hasSelected)
        .toggleClass('btn-outline-warning', !hasSelected);
    $('#collectionBtnText').text(hasSelected ? '컬렉션에 담김' : '컬렉션에 추가');
}
</script>
</body>
</html>
