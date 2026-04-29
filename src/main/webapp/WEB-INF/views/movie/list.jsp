<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>영화 목록 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    .movie-card { cursor: pointer; transition: transform 0.2s; }
    .movie-card:hover { transform: scale(1.05); }
    .movie-poster { width: 100%; height: 280px; object-fit: cover; border-radius: 8px; }
    .section-title { border-left: 4px solid #28a745; padding-left: 12px; }
    .tab-btn { background: none; border: none; color: #aaa; font-size: 16px; padding: 8px 16px; cursor: pointer; }
    .tab-btn.active { color: #28a745; border-bottom: 2px solid #28a745; }
    .filter-box { background:#1f1f1f; border:1px solid rgba(255,255,255,0.08); border-radius:14px; padding:16px; }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>
<%@ include file="/WEB-INF/views/common/contentQuickActions.jspf" %>

<div class="container py-4">
  <div class="filter-box mb-4">
    <form action="${ctp}/movie/list" method="get" class="row g-3 align-items-end">
      <input type="hidden" name="page" value="1">
      <input type="hidden" name="tab" id="tabInput" value="${activeTab}">
      <%@ include file="/WEB-INF/views/common/countrySelect.jspf" %>
      <div class="col-12 col-md-auto">
        <button type="submit" class="btn btn-success px-4">적용</button>
      </div>
    </form>
  </div>

  <div class="d-flex gap-2 border-bottom border-secondary pb-2 mb-4">
    <button type="button" class="tab-btn ${activeTab == 'popular' ? 'active' : ''}" onclick="switchTab(this,'popular')">인기</button>
    <button type="button" class="tab-btn ${activeTab == 'nowplaying' ? 'active' : ''}" onclick="switchTab(this,'nowplaying')">현재 상영중</button>
    <button type="button" class="tab-btn ${activeTab == 'toprated' ? 'active' : ''}" onclick="switchTab(this,'toprated')">평점 높은 작품</button>
  </div>

  <div id="tab-popular" style="${activeTab != 'popular' ? 'display:none;' : ''}">
    <h4 class="section-title mb-4">인기 영화</h4>
    <div class="row g-3">
      <c:forEach var="movie" items="${popularList}">
        <div class="col-6 col-md-2">
          <div class="movie-card sg-card" onclick="sgOpenDetail('${ctp}/movie/detail/${movie.tmdbId}?from=movie&country=${country}&page=${page}&tab=popular')">
            <div class="sg-quick-actions">
              <button type="button" class="sg-quick-btn sg-quick-watch" data-tmdb-id="${movie.tmdbId}" title="보고싶어요" onclick="sgToggleWatch(event, this)">
                <i class="fa fa-heart"></i>
              </button>
              <button type="button" class="sg-quick-btn sg-quick-watched" data-tmdb-id="${movie.tmdbId}" title="봤어요" onclick="sgToggleWatched(event, this)">
                <i class="fa fa-check"></i>
              </button>
              <button type="button" class="sg-quick-btn sg-quick-collection" data-tmdb-id="${movie.tmdbId}" title="컬렉션" onclick="sgOpenCollection(event, this)">
                <i class="fa fa-folder-plus"></i>
              </button>
            </div>
            <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}" class="movie-poster mb-2"
                 onerror="this.src='https://placehold.co/200x280?text=No+Image'">
            <p class="mb-0 fw-bold text-truncate small">${movie.title}</p>
            <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
            <p class="text-secondary mb-0 small">${movie.releaseDate}</p>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div id="tab-nowplaying" style="${activeTab == 'nowplaying' ? '' : 'display:none;'}">
    <h4 class="section-title mb-4">현재 상영중</h4>
    <div class="row g-3">
      <c:forEach var="movie" items="${nowPlayingList}">
        <div class="col-6 col-md-2">
          <div class="movie-card sg-card" onclick="sgOpenDetail('${ctp}/movie/detail/${movie.tmdbId}?from=movie&country=${country}&page=${page}&tab=nowplaying')">
            <div class="sg-quick-actions">
              <button type="button" class="sg-quick-btn sg-quick-watch" data-tmdb-id="${movie.tmdbId}" title="보고싶어요" onclick="sgToggleWatch(event, this)">
                <i class="fa fa-heart"></i>
              </button>
              <button type="button" class="sg-quick-btn sg-quick-watched" data-tmdb-id="${movie.tmdbId}" title="봤어요" onclick="sgToggleWatched(event, this)">
                <i class="fa fa-check"></i>
              </button>
              <button type="button" class="sg-quick-btn sg-quick-collection" data-tmdb-id="${movie.tmdbId}" title="컬렉션" onclick="sgOpenCollection(event, this)">
                <i class="fa fa-folder-plus"></i>
              </button>
            </div>
            <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}" class="movie-poster mb-2"
                 onerror="this.src='https://placehold.co/200x280?text=No+Image'">
            <p class="mb-0 fw-bold text-truncate small">${movie.title}</p>
            <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
            <p class="text-secondary mb-0 small">${movie.releaseDate}</p>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div id="tab-toprated" style="${activeTab == 'toprated' ? '' : 'display:none;'}">
    <h4 class="section-title mb-4">평점 높은 영화</h4>
    <div class="row g-3">
      <c:forEach var="movie" items="${topRatedList}">
        <div class="col-6 col-md-2">
          <div class="movie-card sg-card" onclick="sgOpenDetail('${ctp}/movie/detail/${movie.tmdbId}?from=movie&country=${country}&page=${page}&tab=toprated')">
            <div class="sg-quick-actions">
              <button type="button" class="sg-quick-btn sg-quick-watch" data-tmdb-id="${movie.tmdbId}" title="보고싶어요" onclick="sgToggleWatch(event, this)">
                <i class="fa fa-heart"></i>
              </button>
              <button type="button" class="sg-quick-btn sg-quick-watched" data-tmdb-id="${movie.tmdbId}" title="봤어요" onclick="sgToggleWatched(event, this)">
                <i class="fa fa-check"></i>
              </button>
              <button type="button" class="sg-quick-btn sg-quick-collection" data-tmdb-id="${movie.tmdbId}" title="컬렉션" onclick="sgOpenCollection(event, this)">
                <i class="fa fa-folder-plus"></i>
              </button>
            </div>
            <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}" class="movie-poster mb-2"
                 onerror="this.src='https://placehold.co/200x280?text=No+Image'">
            <p class="mb-0 fw-bold text-truncate small">${movie.title}</p>
            <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
            <p class="text-secondary mb-0 small">${movie.releaseDate}</p>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div class="d-flex justify-content-center mt-5 gap-2">
    <c:if test="${page > 1}">
      <a id="prevPageLink" href="${ctp}/movie/list?page=${page-1}&country=${country}&tab=${activeTab}" class="btn btn-outline-secondary">이전</a>
    </c:if>
    <span class="btn btn-success disabled">${page} 페이지</span>
    <a id="nextPageLink" href="${ctp}/movie/list?page=${page+1}&country=${country}&tab=${activeTab}" class="btn btn-outline-secondary">다음</a>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
function updatePaginationLinks(tabName) {
    var country = encodeURIComponent('${country}');
    var prevLink = document.getElementById('prevPageLink');
    var nextLink = document.getElementById('nextPageLink');

    if (prevLink) {
        prevLink.href = '${ctp}/movie/list?page=${page-1}&country=' + country + '&tab=' + tabName;
    }
    if (nextLink) {
        nextLink.href = '${ctp}/movie/list?page=${page+1}&country=' + country + '&tab=' + tabName;
    }
}

function switchTab(btn, tabName) {
    document.getElementById('tab-popular').style.display = 'none';
    document.getElementById('tab-nowplaying').style.display = 'none';
    document.getElementById('tab-toprated').style.display = 'none';
    document.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
    document.getElementById('tab-' + tabName).style.display = 'block';
    document.getElementById('tabInput').value = tabName;
    updatePaginationLinks(tabName);
    if (window.history && window.history.replaceState) {
        window.history.replaceState(null, '', '${ctp}/movie/list?page=${page}&country=' + encodeURIComponent('${country}') + '&tab=' + tabName);
    }
    btn.classList.add('active');
}
</script>
</body>
</html>
