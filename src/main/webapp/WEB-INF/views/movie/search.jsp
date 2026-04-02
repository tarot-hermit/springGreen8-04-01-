<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>검색 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    .movie-card { cursor:pointer; transition:transform 0.2s; }
    .movie-card:hover { transform:scale(1.05); }
    .movie-poster { width:100%; height:260px; object-fit:cover; border-radius:8px; }
    .search-box { background:#2c2c2c; border-radius:12px; }
    .section-title { border-left:4px solid #28a745; padding-left:12px; }
    /* 인기 검색어 */
    .popular-kw-wrap { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:28px; }
    .kw-chip { display:inline-flex; align-items:center; gap:6px;
               padding:7px 14px; border-radius:999px;
               background:#3a3a3a; color:#e0e0e0; border:1px solid #555;
               font-size:13px; font-weight:600; cursor:pointer; transition:all 0.2s; }
    .kw-chip:hover { background:#ff2f6e; color:#fff; border-color:#ff2f6e; }
    .kw-rank { font-size:11px; font-weight:800; color:#fbbf24; min-width:14px; }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container py-5">

  <!-- 검색창 -->
  <div class="search-box p-4 mb-4">
    <h4 class="mb-3 text-success">영화 검색</h4>
    <form action="${ctp}/movie/search" method="get">
      <div class="input-group">
        <input type="text" class="form-control form-control-lg bg-secondary text-white border-0"
               name="q" id="searchInput" value="${q}"
               placeholder="영화 제목을 입력하세요..." required>
        <button type="submit" class="btn btn-success btn-lg px-4">
          <i class="fa fa-search"></i> 검색
        </button>
      </div>
    </form>
  </div>

  <!-- 최근 검색어 -->
  <c:if test="${not empty historyList}">
    <div class="mt-3 mb-4">
      <div class="d-flex justify-content-between align-items-center mb-2">
        <small class="text-secondary">최근 검색어</small>
        <button class="btn btn-link btn-sm text-secondary p-0" onclick="deleteAllSearch()">전체 삭제</button>
      </div>
      <div class="d-flex flex-wrap gap-2" id="historyArea">
        <c:forEach var="h" items="${historyList}">
          <div class="d-flex align-items-center bg-secondary rounded px-3 py-1"
               id="history-${h.searchNo}">
            <a href="${ctp}/movie/search?q=${h.keyword}"
               class="text-white text-decoration-none small me-2">${h.keyword}</a>
            <span class="text-secondary" style="cursor:pointer;font-size:12px;"
                  onclick="deleteSearch(${h.searchNo})">✕</span>
          </div>
        </c:forEach>
      </div>
    </div>
  </c:if>

  <!-- ── 인기 검색어 TOP 10 (신규) ────────────────────────────── -->
  <c:if test="${not empty popularKeywords}">
    <div class="mb-4">
      <div class="d-flex justify-content-between align-items-center mb-2">
        <small class="text-warning fw-bold">🔥 인기 검색어 TOP 10</small>
      </div>
      <div class="popular-kw-wrap">
        <c:forEach var="kw" items="${popularKeywords}" varStatus="st">
          <a href="${ctp}/movie/search?q=${kw.keyword}" class="kw-chip">
            <span class="kw-rank">${st.index + 1}</span>
            ${kw.keyword}
          </a>
        </c:forEach>
      </div>
    </div>
  </c:if>

  <!-- 검색 결과 -->
  <c:choose>
    <c:when test="${not empty q}">
      <h4 class="section-title mb-4">
        "<span class="text-success">${q}</span>" 검색 결과
        <span class="text-secondary fs-6 ms-2">(${searchList.size()}건)</span>
      </h4>
      <c:choose>
        <c:when test="${not empty searchList}">
          <div class="row g-3 mb-5">
            <c:forEach var="movie" items="${searchList}">
              <div class="col-6 col-md-2">
                <div class="movie-card"
                     onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
                  <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                       class="movie-poster mb-2"
                       onerror="this.src='https://via.placeholder.com/200x260?text=No+Image'">
                  <p class="mb-0 fw-bold text-truncate small">${movie.title}</p>
                  <p class="text-secondary mb-0 small">${movie.releaseDate}</p>
                  <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
                </div>
              </div>
            </c:forEach>
          </div>
          <!-- 페이징 -->
          <div class="d-flex justify-content-center gap-2 mt-4">
            <c:if test="${page > 1}">
              <a href="${ctp}/movie/search?q=${q}&page=${page-1}" class="btn btn-outline-secondary">이전</a>
            </c:if>
            <span class="btn btn-success disabled">${page} 페이지</span>
            <c:if test="${searchList.size() == 20}">
              <a href="${ctp}/movie/search?q=${q}&page=${page+1}" class="btn btn-outline-secondary">다음</a>
            </c:if>
          </div>
        </c:when>
        <c:otherwise>
          <div class="text-center py-5">
            <i class="fa fa-film fa-3x text-secondary mb-3"></i>
            <p class="text-secondary fs-5">"${q}" 에 대한 검색 결과가 없습니다.</p>
            <p class="text-secondary small">다른 검색어로 시도해보세요.</p>
          </div>
        </c:otherwise>
      </c:choose>
    </c:when>
    <c:otherwise>
      <div class="text-center py-5">
        <i class="fa fa-search fa-3x text-secondary mb-3"></i>
        <p class="text-secondary fs-5">검색어를 입력해주세요.</p>
      </div>
    </c:otherwise>
  </c:choose>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
document.getElementById('searchInput').focus();

function deleteSearch(searchNo) {
    $.post('${ctp}/movie/search/delete', { searchNo: searchNo }, function(res) {
        if (res === 'ok') $('#history-' + searchNo).remove();
    });
}

function deleteAllSearch() {
    if (!confirm('검색 기록을 전체 삭제하시겠습니까?')) return;
    $.post('${ctp}/movie/search/deleteAll', function(res) {
        if (res === 'ok') $('#historyArea').parent().remove();
    });
}
</script>
</body>
</html>
