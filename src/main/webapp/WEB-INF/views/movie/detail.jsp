<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="ctp" value="${pageContext.request.contextPath}"/>
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

    .input-group.input-group-sm .form-control {
      border-radius: 14px 0 0 14px !important;
    }

    .input-group.input-group-sm .btn {
      border-radius: 0 14px 14px 0 !important;
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
  <!-- 히어로 영역 -->
  <div class="backdrop">
    <div class="container hero-content">
      <div class="row align-items-end g-4">
        <div class="col-lg-auto text-center text-lg-start">
          <div class="poster-wrap">
            <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                 class="poster-img"
                 onerror="this.src='https://via.placeholder.com/250x375?text=No+Image'">
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
			    <button class="btn btn-outline-warning" onclick="openCollectionModal()">
			      <i class="fa fa-folder-open"></i> 컬렉션에 추가
			    </button>
			  </c:if>
			  <a href="${ctp}/movie/list" class="btn btn-soft-secondary">
			    <i class="fa fa-arrow-left me-1"></i> 목록으로
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
        <div class="content-card mb-4" id="ratingStatsBox" style="display:none;">
		  <h4 class="section-title">별점 분포</h4>
		  <div id="ratingStatsInner"></div>
		</div>
        
		<%-- ① 예고편 --%>
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
				  style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;">
				</iframe>
		      </div>
		      <p class="mt-2 mb-0 text-secondary small">${video.name}</p>
		    </div>
		    </c:forEach>
		  </div>
		</div>
		</c:if>
		
		<%-- ② 출연진 --%>
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
			                 onerror="this.src='https://via.placeholder.com/185x180?text=No+Image'">
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
		
		<%-- ③ 스태프 --%>
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

                <%-- 이미 리뷰 작성한 경우 --%>
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
                                <span class="text-secondary fs-5">★</span>
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

                    <div class="review-body mb-0">${myReview.content}</div>
                  </div>

                  <!-- 수정 폼 -->
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
                                id="editContent" rows="5">${myReview.content}</textarea>
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

                <%-- 리뷰 미작성 --%>
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
		              style="border-radius:999px;font-size:12px;font-weight:700;background:rgba(255,255,255,0.08);color:#aaa;border:1px solid rgba(255,255,255,0.15);">별점높은순</button>
		      <button class="btn btn-sm sort-btn" onclick="sortReviews('rating_low', this)"
		              style="border-radius:999px;font-size:12px;font-weight:700;background:rgba(255,255,255,0.08);color:#aaa;border:1px solid rgba(255,255,255,0.15);">별점낮은순</button>
		      <button class="btn btn-sm sort-btn" onclick="sortReviews('like', this)"
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
      <!-- 오른쪽 정보 -->
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
        <div class="text-center py-3 text-secondary">불러오는 중...</div>
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
var currentSort = 'latest';

$(document).ready(function() {
    loadReviews();
    setEditRating(editRating);

    // ── textarea 실시간 체크 ──
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
            $('#contentMsg').html('<span class="text-success">✓ 작성 가능합니다.</span>');
        }
    }); // ← on('input') 여기서 닫힘

    // ── 봤어요 초기 상태 확인 ──
    $.get(ctp + '/movie/watched/check', { movieNo: tmdbId }, function(res) {
        if (res.watched) {
            $('#watchedBtn').removeClass('btn-outline-info').addClass('btn-info');
            $('#watchedBtnText').text('봤어요 ✓');
        }
    }, 'json');

    // ── 별점 분포 로드 ──
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

    // ── 비슷한 영화 로드 ──
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

}); // ← document.ready 여기서 닫힘

/* ── 별점 선택 ── */
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

/* ── 리뷰 등록 ── */
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
                Swal.fire({ icon: 'info', title: '이미 작성한 리뷰', text: '이 영화에 이미 리뷰를 작성하셨습니다. 기존 리뷰를 수정해주세요.' });
            } else if (res == 'length') {
                Swal.fire({ icon: 'warning', title: '내용 길이 오류', text: '리뷰 내용은 10자 이상 2000자 이하로 작성해주세요.' });
            } else if (res == 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                    .then(() => location.href = ctp + '/user/login');
            } else {
                Swal.fire({ icon: 'error', title: '등록 실패', text: '리뷰 등록에 실패했습니다.' });
            }
        }
    });
}

/* ── 리뷰 수정 ── */
function updateReview(reviewNo) {
    var rating  = $('#editRating').val();
    var content = $('#editContent').val();
    var spoiler = $('#editSpoiler').is(':checked') ? 1 : 0;

    if (!content.trim()) {
        Swal.fire({ icon: 'warning', title: '내용 필요', text: '리뷰 내용을 입력해주세요.' });
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
            } else {
                Swal.fire({ icon: 'error', title: '수정 실패', text: '수정에 실패했습니다.' });
            }
        }
    });
}

/* ── 리뷰 삭제 ── */
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

/* ── 리뷰 목록 ── */
function loadReviews() {
    $.ajax({
        url: ctp + '/review/list', type: 'GET',
        data: { movieNo: tmdbId },
        success: function(list) { renderReviews(list); }
    });
}

/* ── 리뷰 렌더링 (정렬 공용) ── */
function renderReviews(list) {
    var html = '';
    if (list.length == 0) {
        html = '<div class="empty-card"><p class="text-secondary mb-0">아직 작성된 리뷰가 없습니다.</p></div>';
    } else {
        list.forEach(function(r) {
            var stars = '';
            for (var i = 1; i <= 5; i++) {
                stars += i <= r.rating ? '<span class="text-warning">★</span>' : '<span class="text-secondary">★</span>';
            }
            var userInitial = r.userName ? r.userName.substring(0,1) : '?';
            html += '<div class="review-item">';
            html += '<div class="review-header">';
            html += '<div class="review-user">';
            html += '<div class="avatar-circle">' + userInitial + '</div>';
            html += '<div><div class="fw-bold">' + r.userName + '</div>';
            html += '<div class="review-stars">' + stars;
            html += '<span class="text-secondary small ms-2">' + r.rating + '점</span></div></div></div>';
            html += '<small class="text-secondary">' + r.regDate + '</small></div>';
            if (r.spoiler == 1) {
                html += '<div class="spoiler-badge mb-3"><i class="fa fa-exclamation-triangle"></i> 스포일러 포함</div>';
            }
            html += '<div class="review-body">' + r.content + '</div>';
            html += '<div class="review-actions">';
            if (loginUserNo != 0 && r.userNo == loginUserNo) {
                html += '<button class="btn btn-outline-secondary btn-sm like-self" disabled>';
                html += '<i class="fa fa-thumbs-up"></i> <span class="like-cnt">' + r.likeCnt + '</span>';
                html += ' <small>(내 리뷰)</small></button>';
            } else {
                html += '<button class="btn btn-outline-secondary btn-sm" onclick="toggleLike(' + r.reviewNo + ', this)">';
                html += '<i class="fa fa-thumbs-up"></i> <span class="like-cnt">' + r.likeCnt + '</span></button>';
                if (loginUserNo != 0) {
                    html += '<button class="btn btn-outline-danger btn-sm ms-1" onclick="reportReview(' + r.reviewNo + ')">';
                    html += '<i class="fa fa-flag"></i></button>';
                }
            }
            html += '</div>';
            html += '<div class="comment-area"><div id="commentList-' + r.reviewNo + '" class="mb-2"></div>';
            if (loginUserNo != 0) {
                html += '<div class="input-group input-group-sm">';
                html += '<input type="text" class="form-control bg-secondary text-white border-0" id="commentInput-' + r.reviewNo + '" placeholder="댓글을 입력하세요..." maxlength="500">';
                html += '<button class="btn btn-outline-success btn-sm" onclick="writeComment(' + r.reviewNo + ')">등록</button></div>';
            }
            html += '</div></div>';
            loadComments(r.reviewNo);
        });
    }
    $('#reviewList').html(html);
}

/* ── 댓글 목록 ── */
function loadComments(reviewNo) {
    $.ajax({
        url: ctp + '/comment/list', type: 'GET',
        data: { reviewNo: reviewNo },
        success: function(list) {
            var html = '';
            list.forEach(function(c) {
                html += '<div class="comment-item" id="comment-' + c.commentNo + '">';
                html += '<div class="comment-main">';
                html += '<span class="comment-author">' + c.userName + '</span>';
                html += '<span class="comment-text" id="commentText-' + c.commentNo + '">' + c.content + '</span>';
                html += '</div><div class="d-flex gap-2">';
                if (loginUserNo != 0 && c.userNo == loginUserNo) {
                    html += '<span class="comment-link" onclick="editComment(' + c.commentNo + ')">수정</span>';
                    html += '<span class="comment-link" onclick="deleteComment(' + c.commentNo + ', ' + reviewNo + ')">삭제</span>';
                }
                html += '</div></div>';
            });
            $('#commentList-' + reviewNo).html(html);
        }
    });
}

/* ── 댓글 등록 ── */
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
                    .then(() => location.href = ctp + '/user/login');
            }
        }
    });
}

/* ── 댓글 수정 ── */
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

/* ── 댓글 삭제 ── */
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
                if (res == 'ok') $('#comment-' + commentNo).remove();
                else Swal.fire({ icon: 'error', title: '삭제 실패', timer: 1200, showConfirmButton: false });
            }
        });
    });
}

/* ── 찜하기 ── */
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
                    .then(() => location.href = ctp + '/user/login');
            }
        }
    });
}

/* ── 공감 토글 ── */
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
                        .then(() => location.href = ctp + '/user/login');
                }
            }
        });
        </c:when>
        <c:otherwise>
        Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
            .then(() => location.href = ctp + '/user/login');
        </c:otherwise>
    </c:choose>
}

/* ── 컬렉션 모달 열기 ── */
function openCollectionModal() {
    var modal = new bootstrap.Modal(document.getElementById('collectionModal'));
    modal.show();
    $.get(ctp + '/collection/my', function(list) {
        if (list.length === 0) {
            $('#collectionModalBody').html(
                '<p class="text-secondary text-center">컬렉션이 없습니다. ' +
                '<a href="' + ctp + '/collection/list" class="text-warning">만들러 가기</a></p>'
            );
            return;
        }
        var html = '<div class="list-group">';
        list.forEach(function(c) {
            html += '<button class="list-group-item list-group-item-action bg-dark text-white border-secondary"';
            html += ' onclick="addToCollection(' + c.collectionId + ', this)">';
            html += '<div class="d-flex justify-content-between align-items-center">';
            html += '<span>' + c.title + '</span>';
            html += '<span class="col-check"></span>';
            html += '<small class="text-secondary ms-2">' + c.movieCount + '편</small>';
            html += '</div></button>';
        });
        html += '</div>';
        $('#collectionModalBody').html(html);
    }, 'json');
}

/* ── 컬렉션 영화 추가/제거 ── */
function addToCollection(collectionId, btn) {
    $.post(ctp + '/collection/movie/toggle',
        { collectionId: collectionId, movieId: tmdbId },
        function(res) {
            if (res.status === 'added') {
                $(btn).addClass('active');
                $(btn).find('.col-check').text(' ✓');
            } else if (res.status === 'removed') {
                $(btn).removeClass('active');
                $(btn).find('.col-check').text('');
            } else if (res.status === 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' });
            }
        }, 'json');
}

/* ── 리뷰 신고 ── */
function reportReview(reviewNo) {
    document.getElementById('reportTargetId').value = reviewNo;
    document.getElementById('reportReason').value = '';
    new bootstrap.Modal(document.getElementById('reportModal')).show();
}

function submitReport() {
    var targetId = document.getElementById('reportTargetId').value;
    var reason   = document.getElementById('reportReason').value.trim();
    if (!reason) {
        Swal.fire({ icon: 'warning', title: '사유 필요', text: '신고 사유를 입력해주세요.' });
        return;
    }
    $.post(ctp + '/report/insert',
        { targetType: 'REVIEW', targetId: targetId, reason: reason },
        function(res) {
            document.activeElement.blur();
            var modal = bootstrap.Modal.getInstance(document.getElementById('reportModal'));
            modal.hide();
            if (res.status === 'ok') {
                Swal.fire({ icon: 'success', title: '신고 접수', text: '신고가 접수되었습니다.', timer: 1500, showConfirmButton: false });
            } else if (res.status === 'dup') {
                Swal.fire({ icon: 'info', title: '중복 신고', text: '이미 신고한 리뷰입니다.' });
            } else if (res.status === 'login') {
                Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' });
            } else {
                Swal.fire({ icon: 'error', title: '신고 실패', text: '신고 접수에 실패했습니다.' });
            }
        }, 'json');
}
function toggleWatched() {
    $.post(ctp + '/movie/watched/toggle', { movieNo: tmdbId }, function(res) {
        if (res.status === 'added') {
            $('#watchedBtn').removeClass('btn-outline-info').addClass('btn-info');
            $('#watchedBtnText').text('봤어요 ✓');
        } else if (res.status === 'removed') {
            $('#watchedBtn').removeClass('btn-info').addClass('btn-outline-info');
            $('#watchedBtnText').text('봤어요');
        } else if (res.status === 'login') {
            Swal.fire({ icon: 'info', title: '로그인 필요', text: '로그인이 필요합니다.' })
                .then(() => location.href = ctp + '/user/login');
        }
    }, 'json');
}
function sortReviews(sort, btn) {
    currentSort = sort;
    // 탭 스타일 전환
    document.querySelectorAll('.sort-btn').forEach(function(b) {
        b.style.background = 'rgba(255,255,255,0.08)';
        b.style.color = '#aaa';
        b.style.border = '1px solid rgba(255,255,255,0.15)';
    });
    btn.style.background = '#28a745';
    btn.style.color = '#fff';
    btn.style.border = 'none';

    $.get(ctp + '/review/list/sorted',
        { movieNo: tmdbId, sort: sort },
        function(list) {
            renderReviews(list);
        }, 'json');
}
</script>

</body>
</html>