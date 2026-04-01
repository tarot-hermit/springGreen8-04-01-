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
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container py-4">

<!-- 탭 메뉴 -->
	<div class="d-flex gap-2 border-bottom border-secondary pb-2">
		<button class="tab-btn active" onclick="switchTab(this,'popular')">인기</button>
		<button class="tab-btn " onclick="switchTab(this,'nowplaying')">현재 상영중</button>
		<button class="tab-btn" onclick="switchTab(this,'toprated')">최고 평점</button>
	</div>
	
	<!-- 인기 영화 -->
	<div id="tab-popular">
		<h4 class="section-title mb-4">인기 영화</h4>
		<div class="row g-3">
			<c:forEach var="movie" items="${popularList }">
				<div class="col-6 col-md-2" >
					<div class="movie-card"
						onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
						<img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                 class="movie-poster mb-2"
                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
                 <p class="mb-0 fw-bold text-truncate small">${movie.title}</p>
                 <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
                 <p class="text-secondary mb-0 small">${movie.releaseDate}</p>				
					</div>
				</div>
			</c:forEach>
		</div>
	</div>
	
	<!-- 현재 상영중 -->
	<div id="tab-nowplaying" style="display:none;">
		<h4 class="section-title mb-4">현재 상영중</h4>
		<div class="row g-3">
			<c:forEach var="movie" items="${nowPlayingList}">
				<div class="col-6 col-md-2">
					<div class="movie-card"
						onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
						<img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                 class="movie-poster mb-2"
                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
                 <p class="mb-0 fw-bold text-truncate small">${movie.title }</p>
                 <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
                 <p class="text-secondary mb-0 small">${movie.releaseDate}</p>
					</div>
				</div>
			</c:forEach>
		</div>
	</div>
	
	<!-- 최고 평점 -->
	<div id="tab-toprated" style="display:none;">
		<h4 class="section-title mb-4">최고 평점</h4>
		<div class="row g-3">
			<c:forEach var="movie" items="${topRatedList}">
				<div class="col-6 col-md-2">
					<div class="movie-card"
						onclick="location.href='${ctp}/movie/detail/${movie.tmdbId }'">
						  <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                 class="movie-poster mb-2"
                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
                  <p class="mb-0 fw-bold text-truncate small">${movie.title}</p>
		          <p class="text-warning mb-0 small">★ ${movie.voteAverage}</p>
		          <p class="text-secondary mb-0 small">${movie.releaseDate}</p>
					</div>
				</div>
			</c:forEach>
		</div>
	</div>
	
	<!-- 페이징 -->
	<div class="d-flex justify-content-center mt-5 gap-2">
		<c:if test="${page>1}">
		<a href="${ctp}/movie/list?page=${page-1}"
			class="btn btn-outline-secondary">이전</a>
		</c:if>
		<span class="btn btn-success disabled">${page}페이지</span>
		<a href="${ctp}/movie/list?page=${page+1}"
			class="btn btn-outline-secondary">다음</a>
	</div>
</div>
<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
function switchTab(btn, tabName) {
    document.getElementById('tab-popular').style.display = 'none';
    document.getElementById('tab-nowplaying').style.display = 'none';
    document.getElementById('tab-toprated').style.display = 'none';

    document.querySelectorAll('.tab-btn').forEach(function(b) {
        b.classList.remove('active');
    });

    document.getElementById('tab-' + tabName).style.display = 'block';
    btn.classList.add('active');
}
</script>

</body>
</html>