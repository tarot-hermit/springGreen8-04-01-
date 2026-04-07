<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>드라마 목록 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    .content-card { cursor: pointer; transition: transform 0.2s; }
    .content-card:hover { transform: scale(1.04); }
    .content-poster { width: 100%; height: 280px; object-fit: cover; border-radius: 8px; }
    .section-title { border-left: 4px solid #28a745; padding-left: 12px; }
    .tab-btn { background: none; border: none; color: #aaa; font-size: 16px; padding: 8px 16px; cursor: pointer; }
    .tab-btn.active { color: #28a745; border-bottom: 2px solid #28a745; }
    .filter-box { background:#1f1f1f; border:1px solid rgba(255,255,255,0.08); border-radius:14px; padding:16px; }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container py-4">
  <div class="filter-box mb-4">
    <form action="${ctp}/movie/tv" method="get" class="row g-3 align-items-end">
      <input type="hidden" name="page" value="1">
      <%@ include file="/WEB-INF/views/common/countrySelect.jspf" %>
      <div class="col-12 col-md-auto">
        <button type="submit" class="btn btn-success px-4">적용</button>
      </div>
    </form>
  </div>

  <div class="d-flex gap-2 border-bottom border-secondary pb-2 mb-4">
    <button class="tab-btn active" onclick="switchTab(this,'popular')">인기 드라마</button>
    <button class="tab-btn" onclick="switchTab(this,'onair')">방영 중</button>
    <button class="tab-btn" onclick="switchTab(this,'toprated')">평점 높은 작품</button>
  </div>

  <div id="tab-popular">
    <h4 class="section-title mb-4">인기 드라마</h4>
    <div class="row g-3">
      <c:forEach var="item" items="${popularList}">
        <div class="col-6 col-md-2">
          <div class="content-card" onclick="location.href='${ctp}/movie/tv/${item.tmdbId}?from=tv&country=${country}'">
            <img src="https://image.tmdb.org/t/p/w500${item.posterPath}" class="content-poster mb-2"
                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
            <p class="mb-0 fw-bold text-truncate small">${item.title}</p>
            <p class="text-warning mb-0 small">★ ${item.voteAverage}</p>
            <p class="text-secondary mb-0 small">${item.releaseDate}</p>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div id="tab-onair" style="display:none;">
    <h4 class="section-title mb-4">방영 중인 드라마</h4>
    <div class="row g-3">
      <c:forEach var="item" items="${onTheAirList}">
        <div class="col-6 col-md-2">
          <div class="content-card" onclick="location.href='${ctp}/movie/tv/${item.tmdbId}?from=tv&country=${country}'">
            <img src="https://image.tmdb.org/t/p/w500${item.posterPath}" class="content-poster mb-2"
                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
            <p class="mb-0 fw-bold text-truncate small">${item.title}</p>
            <p class="text-warning mb-0 small">★ ${item.voteAverage}</p>
            <p class="text-secondary mb-0 small">${item.releaseDate}</p>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div id="tab-toprated" style="display:none;">
    <h4 class="section-title mb-4">평점 높은 드라마</h4>
    <div class="row g-3">
      <c:forEach var="item" items="${topRatedList}">
        <div class="col-6 col-md-2">
          <div class="content-card" onclick="location.href='${ctp}/movie/tv/${item.tmdbId}?from=tv&country=${country}'">
            <img src="https://image.tmdb.org/t/p/w500${item.posterPath}" class="content-poster mb-2"
                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
            <p class="mb-0 fw-bold text-truncate small">${item.title}</p>
            <p class="text-warning mb-0 small">★ ${item.voteAverage}</p>
            <p class="text-secondary mb-0 small">${item.releaseDate}</p>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div class="d-flex justify-content-center mt-5 gap-2">
    <c:if test="${page > 1}">
      <a href="${ctp}/movie/tv?page=${page-1}&country=${country}" class="btn btn-outline-secondary">이전</a>
    </c:if>
    <span class="btn btn-success disabled">${page} 페이지</span>
    <a href="${ctp}/movie/tv?page=${page+1}&country=${country}" class="btn btn-outline-secondary">다음</a>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
function switchTab(btn, tabName) {
    document.getElementById('tab-popular').style.display = 'none';
    document.getElementById('tab-onair').style.display = 'none';
    document.getElementById('tab-toprated').style.display = 'none';
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('tab-' + tabName).style.display = 'block';
    btn.classList.add('active');
}
</script>
</body>
</html>
