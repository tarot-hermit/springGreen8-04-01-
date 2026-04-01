<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${genreName} - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    :root {
      --sg-bg: #121212;
      --sg-surface: rgba(255,255,255,0.06);
      --sg-surface-2: rgba(255,255,255,0.09);
      --sg-border: rgba(255,255,255,0.12);
      --sg-text-muted: #b8b8b8;
      --sg-green: #28a745;
      --sg-green-soft: rgba(40,167,69,0.14);
      --sg-shadow: 0 18px 40px rgba(0,0,0,0.35);
      --sg-radius-xl: 24px;
      --sg-radius-lg: 18px;
      --sg-radius-md: 14px;
    }

    body.bg-dark {
      background:
        radial-gradient(circle at top right, rgba(40,167,69,0.10), transparent 24%),
        radial-gradient(circle at top left, rgba(255,255,255,0.04), transparent 20%),
        var(--sg-bg) !important;
      color: #fff;
    }

    .genre-page {
      min-height: 100vh;
    }

    .hero-box {
      position: relative;
      overflow: hidden;
      border-radius: 28px;
      padding: 42px 34px;
      margin-bottom: 28px;
      background:
        linear-gradient(135deg, rgba(40,167,69,0.22), rgba(255,255,255,0.04)),
        linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.03));
      border: 1px solid rgba(255,255,255,0.10);
      box-shadow: 0 20px 45px rgba(0,0,0,0.28);
      backdrop-filter: blur(12px);
    }

    .hero-box::before {
      content: '';
      position: absolute;
      right: -80px;
      top: -80px;
      width: 220px;
      height: 220px;
      border-radius: 50%;
      background: rgba(40,167,69,0.16);
      filter: blur(10px);
    }

    .hero-box::after {
      content: '';
      position: absolute;
      left: -40px;
      bottom: -70px;
      width: 180px;
      height: 180px;
      border-radius: 50%;
      background: rgba(255,255,255,0.05);
      filter: blur(10px);
    }

    .hero-content {
      position: relative;
      z-index: 2;
    }

    .hero-badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 8px 14px;
      border-radius: 999px;
      background: rgba(255,255,255,0.08);
      border: 1px solid rgba(255,255,255,0.10);
      font-size: 0.9rem;
      margin-bottom: 14px;
    }

    .hero-title {
      font-size: clamp(2rem, 4vw, 3rem);
      font-weight: 800;
      letter-spacing: -0.03em;
      line-height: 1.1;
      margin-bottom: 10px;
    }

    .hero-desc {
      color: rgba(255,255,255,0.72);
      font-size: 1rem;
      margin-bottom: 0;
    }

    .section-card {
      background: linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.04));
      border: 1px solid var(--sg-border);
      border-radius: var(--sg-radius-xl);
      box-shadow: var(--sg-shadow);
      backdrop-filter: blur(12px);
      padding: 28px;
      margin-bottom: 28px;
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

    .genre-badge {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-height: 42px;
      padding: 9px 17px;
      border-radius: 999px;
      cursor: pointer;
      font-size: 14px;
      font-weight: 600;
      transition: all 0.2s ease;
      background: rgba(255,255,255,0.06);
      border: 1px solid rgba(255,255,255,0.10);
      color: #f8f9fa !important;
      text-decoration: none;
      box-shadow: inset 0 1px 0 rgba(255,255,255,0.04);
    }

    .genre-badge:hover {
      transform: translateY(-2px);
      background: rgba(40,167,69,0.20);
      border-color: rgba(40,167,69,0.35);
      color: #fff !important;
    }

    .genre-badge.active {
      background: linear-gradient(135deg, rgba(40,167,69,0.95), rgba(40,167,69,0.72));
      border-color: rgba(40,167,69,0.95);
      color: #fff !important;
      box-shadow: 0 10px 22px rgba(40,167,69,0.25);
    }

    .sub-title-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 12px;
      flex-wrap: wrap;
      margin-bottom: 22px;
    }

    .sub-title-row .sort-text {
      color: var(--sg-text-muted);
      font-size: 0.95rem;
    }

    .movie-grid {
      row-gap: 22px;
    }

    .movie-card {
      cursor: pointer;
      height: 100%;
      border-radius: 20px;
      overflow: hidden;
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.08);
      transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
      box-shadow: 0 10px 24px rgba(0,0,0,0.18);
    }

    .movie-card:hover {
      transform: translateY(-6px);
      box-shadow: 0 20px 36px rgba(0,0,0,0.28);
      border-color: rgba(255,255,255,0.16);
    }

    .movie-thumb {
      position: relative;
      overflow: hidden;
      background: #1d1d1d;
    }

    .movie-poster {
      width: 100%;
      height: 300px;
      object-fit: cover;
      display: block;
      transition: transform 0.25s ease;
    }

    .movie-card:hover .movie-poster {
      transform: scale(1.04);
    }

    .movie-score {
      position: absolute;
      top: 12px;
      right: 12px;
      padding: 6px 10px;
      border-radius: 999px;
      background: rgba(0,0,0,0.65);
      color: #ffc107;
      font-size: 0.82rem;
      font-weight: 700;
      backdrop-filter: blur(8px);
      border: 1px solid rgba(255,255,255,0.08);
    }

    .movie-body {
      padding: 14px 14px 16px 14px;
    }

    .movie-title {
      font-size: 0.97rem;
      font-weight: 700;
      color: #fff;
      margin-bottom: 6px;
      line-height: 1.4;
    }

    .movie-date {
      color: var(--sg-text-muted);
      font-size: 0.86rem;
      margin-bottom: 0;
    }

    .empty-box {
      text-align: center;
      padding: 70px 20px;
      border-radius: 22px;
      background: rgba(255,255,255,0.04);
      border: 1px dashed rgba(255,255,255,0.12);
    }

    .empty-box i {
      opacity: 0.7;
    }

    .pagination-wrap {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 10px;
      flex-wrap: wrap;
      margin-top: 30px;
    }

    .pagination-wrap .btn {
      min-width: 90px;
      border-radius: 999px;
      font-weight: 600;
      padding: 10px 16px;
    }

    .page-pill {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      min-width: 110px;
      padding: 10px 18px;
      border-radius: 999px;
      background: linear-gradient(135deg, rgba(40,167,69,0.95), rgba(40,167,69,0.72));
      color: #fff;
      font-weight: 700;
      border: 1px solid rgba(40,167,69,0.95);
      box-shadow: 0 12px 24px rgba(40,167,69,0.22);
    }

    @media (max-width: 991px) {
      .section-card {
        padding: 22px;
      }

      .movie-poster {
        height: 270px;
      }
    }

    @media (max-width: 767px) {
      .hero-box {
        padding: 30px 22px;
        border-radius: 22px;
      }

      .section-card {
        padding: 18px;
        border-radius: 20px;
      }

      .movie-poster {
        height: 250px;
      }

      .genre-badge {
        font-size: 13px;
        padding: 8px 14px;
      }
    }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container py-4 genre-page">

  <!-- 상단 히어로 -->
  <div class="hero-box">
    <div class="hero-content">
      <div class="hero-badge">
        <i class="fa fa-film"></i>
        <span>Genre Explore</span>
      </div>
      <h1 class="hero-title">
        <c:choose>
          <c:when test="${not empty genreName}">
            ${genreName} 영화 탐색
          </c:when>
          <c:otherwise>
            장르별 영화 탐색
          </c:otherwise>
        </c:choose>
      </h1>
      <p class="hero-desc">
        원하는 장르를 선택해서 인기 영화를 한눈에 둘러보세요.
      </p>
    </div>
  </div>

  <!-- 장르 버튼 목록 -->
  <div class="section-card">
    <h5 class="section-title">장르별 탐색</h5>
    <div class="d-flex flex-wrap gap-2">
      <a href="${ctp}/movie/genre?genreId=28&genreName=액션"
         class="genre-badge ${genreId == 28 ? 'active' : ''}">액션</a>
      <a href="${ctp}/movie/genre?genreId=12&genreName=모험"
         class="genre-badge ${genreId == 12 ? 'active' : ''}">모험</a>
      <a href="${ctp}/movie/genre?genreId=16&genreName=애니메이션"
         class="genre-badge ${genreId == 16 ? 'active' : ''}">애니메이션</a>
      <a href="${ctp}/movie/genre?genreId=35&genreName=코미디"
         class="genre-badge ${genreId == 35 ? 'active' : ''}">코미디</a>
      <a href="${ctp}/movie/genre?genreId=80&genreName=범죄"
         class="genre-badge ${genreId == 80 ? 'active' : ''}">범죄</a>
      <a href="${ctp}/movie/genre?genreId=18&genreName=드라마"
         class="genre-badge ${genreId == 18 ? 'active' : ''}">드라마</a>
      <a href="${ctp}/movie/genre?genreId=14&genreName=판타지"
         class="genre-badge ${genreId == 14 ? 'active' : ''}">판타지</a>
      <a href="${ctp}/movie/genre?genreId=27&genreName=공포"
         class="genre-badge ${genreId == 27 ? 'active' : ''}">공포</a>
      <a href="${ctp}/movie/genre?genreId=10749&genreName=로맨스"
         class="genre-badge ${genreId == 10749 ? 'active' : ''}">로맨스</a>
      <a href="${ctp}/movie/genre?genreId=878&genreName=SF"
         class="genre-badge ${genreId == 878 ? 'active' : ''}">SF</a>
      <a href="${ctp}/movie/genre?genreId=53&genreName=스릴러"
         class="genre-badge ${genreId == 53 ? 'active' : ''}">스릴러</a>
      <a href="${ctp}/movie/genre?genreId=10752&genreName=전쟁"
         class="genre-badge ${genreId == 10752 ? 'active' : ''}">전쟁</a>
      <a href="${ctp}/movie/genre?genreId=9648&genreName=미스터리"
         class="genre-badge ${genreId == 9648 ? 'active' : ''}">미스터리</a>
      <a href="${ctp}/movie/genre?genreId=99&genreName=다큐멘터리"
         class="genre-badge ${genreId == 99 ? 'active' : ''}">다큐멘터리</a>
      <a href="${ctp}/movie/genre?genreId=10751&genreName=가족"
         class="genre-badge ${genreId == 10751 ? 'active' : ''}">가족</a>
      <a href="${ctp}/movie/genre?genreId=36&genreName=역사"
         class="genre-badge ${genreId == 36 ? 'active' : ''}">역사</a>
    </div>
  </div>

  <!-- 장르별 영화 목록 -->
  <c:if test="${not empty genreName}">
    <div class="section-card">
      <div class="sub-title-row">
        <h4 class="section-title mb-0">${genreName}</h4>
        <span class="sort-text">인기순</span>
      </div>

      <c:choose>
        <c:when test="${not empty genreList}">
          <div class="row movie-grid">
            <c:forEach var="movie" items="${genreList}">
              <div class="col-6 col-md-4 col-lg-3 col-xl-2">
                <div class="movie-card"
                     onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
                  <div class="movie-thumb">
                    <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                         class="movie-poster"
                         onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
                    <div class="movie-score">★ ${movie.voteAverage}</div>
                  </div>
                  <div class="movie-body">
                    <p class="movie-title text-truncate mb-1">${movie.title}</p>
                    <p class="movie-date">${movie.releaseDate}</p>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>

          <!-- 페이징 -->
          <div class="pagination-wrap">
            <c:if test="${page > 1}">
              <a href="${ctp}/movie/genre?genreId=${genreId}&genreName=${genreName}&page=${page-1}"
                 class="btn btn-outline-secondary">이전</a>
            </c:if>

            <span class="page-pill">${page} 페이지</span>

            <a href="${ctp}/movie/genre?genreId=${genreId}&genreName=${genreName}&page=${page+1}"
               class="btn btn-outline-secondary">다음</a>
          </div>
        </c:when>

        <c:otherwise>
          <div class="empty-box">
            <i class="fa fa-film fa-3x text-secondary mb-3"></i>
            <p class="text-secondary mb-0">해당 장르의 영화가 없습니다.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </c:if>

  <!-- 장르 미선택 안내 -->
  <c:if test="${empty genreName}">
    <div class="section-card">
      <div class="empty-box">
        <i class="fa fa-film fa-3x text-secondary mb-3"></i>
        <p class="text-secondary fs-5 mb-0">위에서 장르를 선택해주세요.</p>
      </div>
    </div>
  </c:if>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>