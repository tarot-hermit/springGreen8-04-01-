<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>트렌딩 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background:#0f0f0f; color:#e0e0e0; }
    .page-wrap { max-width:1200px; margin:0 auto; padding:40px 20px; }

    .page-header { margin-bottom:28px; }
    .page-title  { font-size:1.8rem; font-weight:800; }
    .page-desc   { font-size:14px; color:#888; margin-top:6px; }

    /* 탭 */
    .tab-wrap { display:flex; gap:8px; margin-bottom:28px; }
    .tab-btn  { padding:9px 22px; border-radius:999px; border:1px solid #333;
                background:transparent; color:#888; font-size:14px; font-weight:600;
                cursor:pointer; transition:all 0.2s; }
    .tab-btn.active,
    .tab-btn:hover { background:#e50914; color:#fff; border-color:#e50914; }

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
    .movie-rank  { font-size:1.4rem; font-weight:900; color:#e50914;
                   margin-bottom:4px; line-height:1; }

    .empty { text-align:center; padding:80px 0; color:#555; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="page-wrap">
  <div class="page-header">
    <div class="page-title">🔥 트렌딩</div>
    <div class="page-desc">지금 가장 화제가 되는 영화를 확인해보세요</div>
  </div>

  <!-- 기간 탭 -->
  <div class="tab-wrap">
    <button class="tab-btn ${timeWindow == 'day'  ? 'active' : ''}"
            onclick="location.href='${ctp}/movie/trending?timeWindow=day'">오늘</button>
    <button class="tab-btn ${timeWindow == 'week' ? 'active' : ''}"
            onclick="location.href='${ctp}/movie/trending?timeWindow=week'">이번 주</button>
  </div>

  <!-- 영화 그리드 -->
  <c:choose>
    <c:when test="${not empty movies}">
      <div class="movie-grid">
        <c:forEach var="movie" items="${movies}" varStatus="st">
          <div class="movie-card"
               onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
            <div class="movie-rank">${st.index + 1}</div>
            <img src="https://image.tmdb.org/t/p/w300${movie.posterPath}"
                 alt="${movie.title}"
                 onerror="this.src='https://via.placeholder.com/160x240?text=No+Image'">
            <div class="movie-info">
              <div class="movie-title">${movie.title}</div>
              <div class="movie-meta">
                ★ ${movie.voteAverage} · ${movie.releaseDate}
              </div>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <div class="empty">트렌딩 영화를 불러올 수 없습니다.</div>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
