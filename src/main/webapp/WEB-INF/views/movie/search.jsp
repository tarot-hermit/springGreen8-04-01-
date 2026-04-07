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
    .movie-card:hover { transform:scale(1.04); }
    .movie-poster { width:100%; height:260px; object-fit:cover; border-radius:8px; }
    .search-box { background:#2c2c2c; border-radius:12px; }
    .section-title { border-left:4px solid #28a745; padding-left:12px; }
    .filter-select { min-width:140px; }
    .type-badge,
    .animation-badge,
    .country-badge {
      display:inline-flex;
      align-items:center;
      padding:4px 8px;
      border-radius:999px;
      font-size:11px;
      font-weight:700;
      margin-right:4px;
      margin-bottom:6px;
    }
    .type-badge { background:#1f6feb; color:#fff; }
    .animation-badge { background:#7c3aed; color:#fff; }
    .country-badge { background:#374151; color:#e5e7eb; }
    .popular-kw-wrap { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:28px; }
    .kw-chip {
      display:inline-flex; align-items:center; gap:6px;
      padding:7px 14px; border-radius:999px;
      background:#3a3a3a; color:#e0e0e0; border:1px solid #555;
      font-size:13px; font-weight:600; cursor:pointer; transition:all 0.2s;
    }
    .kw-chip:hover { background:#ff2f6e; color:#fff; border-color:#ff2f6e; }
    .kw-rank { font-size:11px; font-weight:800; color:#fbbf24; min-width:14px; }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container py-5">
  <div class="search-box p-4 mb-4">
    <h4 class="mb-3 text-success">콘텐츠 검색</h4>
    <form action="${ctp}/movie/search" method="get">
      <div class="row g-3 align-items-end">
        <div class="col-12 col-lg">
          <label class="form-label small text-secondary mb-2">검색어</label>
          <input type="text" class="form-control form-control-lg bg-secondary text-white border-0"
                 name="q" id="searchInput" value="${q}"
                 placeholder="영화, 드라마, 애니메이션 제목을 입력하세요.." required>
        </div>
        <div class="col-6 col-md-3 col-lg-2">
          <label class="form-label small text-secondary mb-2">유형</label>
          <select name="mediaType" class="form-select bg-secondary text-white border-0 filter-select">
            <option value="all" ${mediaType == 'all' ? 'selected' : ''}>전체</option>
            <option value="movie" ${mediaType == 'movie' ? 'selected' : ''}>영화</option>
            <option value="tv" ${mediaType == 'tv' ? 'selected' : ''}>드라마/시리즈</option>
            <option value="animation" ${mediaType == 'animation' ? 'selected' : ''}>애니메이션</option>
          </select>
        </div>
        <c:set var="countrySelectWrapperClass" value="col-6 col-md-3 col-lg-2"/>
          <c:set var="countrySelectClass" value="form-select bg-secondary text-white border-0 filter-select"/>
          <%@ include file="/WEB-INF/views/common/countrySelect.jspf" %>
          <c:remove var="countrySelectWrapperClass"/>
          <c:remove var="countrySelectClass"/>
        <div class="col-12 col-lg-2">
          <button type="submit" class="btn btn-success btn-lg px-4 w-100">
            <i class="fa fa-search"></i> 검색
          </button>
        </div>
      </div>
    </form>
  </div>

  <c:if test="${not empty historyList}">
    <div class="mt-3 mb-4">
      <div class="d-flex justify-content-between align-items-center mb-2">
        <small class="text-secondary">최근 검색어</small>
        <button class="btn btn-link btn-sm text-secondary p-0" onclick="deleteAllSearch()">전체 삭제</button>
      </div>
      <div class="d-flex flex-wrap gap-2" id="historyArea">
        <c:forEach var="h" items="${historyList}">
          <div class="d-flex align-items-center bg-secondary rounded px-3 py-1" id="history-${h.searchNo}">
            <a href="${ctp}/movie/search?q=${h.keyword}" class="text-white text-decoration-none small me-2">${h.keyword}</a>
            <span class="text-secondary" style="cursor:pointer;font-size:12px;" onclick="deleteSearch(${h.searchNo})">×</span>
          </div>
        </c:forEach>
      </div>
    </div>
  </c:if>

  <c:if test="${not empty popularKeywords}">
    <div class="mb-4">
      <div class="d-flex justify-content-between align-items-center mb-2">
        <small class="text-warning fw-bold">인기 검색어 TOP 10</small>
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

  <c:choose>
    <c:when test="${not empty q}">
      <h4 class="section-title mb-4">
        "<span class="text-success">${q}</span>" 검색 결과
        <span class="text-secondary fs-6 ms-2">(${searchList.size()}건 표시)</span>
      </h4>
      <c:choose>
        <c:when test="${not empty searchList}">
          <div class="row g-3 mb-5">
            <c:forEach var="item" items="${searchList}">
              <div class="col-6 col-md-3 col-xl-2">
                <div class="movie-card"
                     onclick="location.href='${ctp}/movie/${item.mediaType == 'tv' ? 'tv/' : 'detail/'}${item.tmdbId}'">
                  <img src="https://image.tmdb.org/t/p/w500${item.posterPath}"
                       class="movie-poster mb-2"
                       onerror="this.src='https://via.placeholder.com/200x260?text=No+Image'">
                  <div>
                    <span class="type-badge">${item.mediaType == 'tv' ? 'TV' : 'MOVIE'}</span>
                    <c:if test="${item.animation}">
                      <span class="animation-badge">ANIMATION</span>
                    </c:if>
                    <c:forEach var="origin" items="${item.originCountries}" end="0">
                      <span class="country-badge">${origin}</span>
                    </c:forEach>
                  </div>
                  <p class="mb-0 fw-bold text-truncate small">${item.title}</p>
                  <p class="text-secondary mb-0 small text-truncate">${item.originalTitle}</p>
                  <p class="text-secondary mb-0 small">${item.releaseDate}</p>
                  <p class="text-warning mb-0 small">★${item.voteAverage}</p>
                </div>
              </div>
            </c:forEach>
          </div>
          <div class="d-flex justify-content-center gap-2 mt-4">
            <c:if test="${page > 1}">
              <a href="${ctp}/movie/search?q=${q}&page=${page-1}&mediaType=${mediaType}&country=${country}" class="btn btn-outline-secondary">이전</a>
            </c:if>
            <span class="btn btn-success disabled">${page} 페이지</span>
            <c:if test="${searchResult.hasNextPage}">
              <a href="${ctp}/movie/search?q=${q}&page=${page+1}&mediaType=${mediaType}&country=${country}" class="btn btn-outline-secondary">다음</a>
            </c:if>
          </div>
        </c:when>
        <c:otherwise>
          <div class="text-center py-5">
            <i class="fa fa-film fa-3x text-secondary mb-3"></i>
            <p class="text-secondary fs-5">"${q}" 에 대한 검색 결과가 없습니다.</p>
            <p class="text-secondary small">다른 검색어나 필터로 다시 시도해보세요.</p>
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
