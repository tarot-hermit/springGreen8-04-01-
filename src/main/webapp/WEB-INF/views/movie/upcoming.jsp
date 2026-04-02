<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>개봉 예정 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background:#0f0f0f; color:#e0e0e0; }
    .page-wrap { max-width:1200px; margin:0 auto; padding:40px 20px; }

    .page-header { margin-bottom:28px; }
    .page-title  { font-size:1.8rem; font-weight:800; }
    .page-desc   { font-size:14px; color:#888; margin-top:6px; }

    /* 영화 그리드 */
    .movie-grid { display:grid;
                  grid-template-columns:repeat(auto-fill, minmax(160px, 1fr));
                  gap:20px; }
    .movie-card { cursor:pointer; }
    .movie-card img { width:100%; aspect-ratio:2/3; object-fit:cover;
                      border-radius:10px; transition:opacity .2s; display:block; }
    .movie-card:hover img { opacity:.8; }
    .movie-info  { padding:8px 2px 0; }
    .movie-title { font-size:13px; font-weight:700;
                   white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .movie-meta  { font-size:12px; color:#888; margin-top:2px; }
    .release-badge { display:inline-block; font-size:11px; font-weight:700;
                     padding:2px 8px; border-radius:999px; margin-top:4px;
                     background:rgba(229,9,20,0.15); color:#e50914; }

    /* 페이징 */
    .paging { display:flex; justify-content:center; align-items:center;
              gap:8px; margin-top:40px; }
    .paging a, .paging span { padding:8px 18px; border-radius:8px; font-size:14px;
                               font-weight:600; }
    .paging a { background:#1a1a1a; color:#e0e0e0; border:1px solid #333;
                text-decoration:none; transition:all .2s; }
    .paging a:hover { background:#e50914; color:#fff; border-color:#e50914; }
    .paging span { background:#e50914; color:#fff; }

    .empty { text-align:center; padding:80px 0; color:#555; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="page-wrap">
  <div class="page-header">
    <div class="page-title">🎬 개봉 예정</div>
    <div class="page-desc">곧 극장에서 만날 수 있는 기대작들</div>
  </div>

  <!-- 영화 그리드 -->
  <c:choose>
    <c:when test="${not empty movies}">
      <div class="movie-grid">
        <c:forEach var="movie" items="${movies}">
          <div class="movie-card"
               onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
            <img src="https://image.tmdb.org/t/p/w300${movie.posterPath}"
                 alt="${movie.title}"
                 onerror="this.src='https://via.placeholder.com/160x240?text=No+Image'">
            <div class="movie-info">
              <div class="movie-title">${movie.title}</div>
              <div class="movie-meta">★ ${movie.voteAverage}</div>
              <c:if test="${not empty movie.releaseDate}">
                <span class="release-badge">${movie.releaseDate}</span>
              </c:if>
            </div>
          </div>
        </c:forEach>
      </div>

      <!-- 페이징 -->
      <div class="paging">
        <c:if test="${currentPage > 1}">
          <a href="${ctp}/movie/upcoming?page=${currentPage - 1}">이전</a>
        </c:if>
        <span>${currentPage} 페이지</span>
        <c:if test="${movies.size() == 20}">
          <a href="${ctp}/movie/upcoming?page=${currentPage + 1}">다음</a>
        </c:if>
      </div>
    </c:when>
    <c:otherwise>
      <div class="empty">개봉 예정 영화를 불러올 수 없습니다.</div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
