<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>${collection.title}</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background:#0f0f0f; color:#e0e0e0; }
    .page-wrap { max-width:960px; margin:0 auto; padding:40px 20px; }
    .col-header { margin-bottom:32px; }
    .col-title  { font-size:1.8rem; font-weight:800; }
    .col-meta   { font-size:13px; color:#888; margin-top:6px; }
    .movie-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(140px,1fr)); gap:16px; }
    .movie-card { position:relative; cursor:pointer; }
    .movie-card img { width:100%; border-radius:8px; aspect-ratio:2/3; object-fit:cover; }
    .movie-title { font-size:12px; margin-top:6px; text-align:center;
                   white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .remove-btn { position:absolute; top:6px; right:6px;
                  background:rgba(229,9,20,0.85); color:#fff; border:none;
                  border-radius:50%; width:24px; height:24px; font-size:14px;
                  line-height:1; cursor:pointer; display:none; }
    .movie-card:hover .remove-btn { display:block; }
    .empty { text-align:center; padding:60px 0; color:#555; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>
<div class="page-wrap">
  <div class="col-header">
    <div class="d-flex justify-content-between align-items-start">
      <div>
        <div class="col-title">${collection.title}</div>
        <div class="col-meta">
          ${collection.mid} · ${collection.movieCount}편 ·
          <span>${collection.isPublic == 1 ? '공개' : '비공개'}</span>
        </div>
        <c:if test="${not empty collection.description}">
          <p style="margin-top:10px;color:#aaa;font-size:14px;">${collection.description}</p>
        </c:if>
      </div>
      <c:if test="${sessionScope.loginUser.userId == collection.mid}">
        <div class="d-flex gap-2">
          <button class="btn btn-outline-secondary btn-sm" onclick="openEdit()">수정</button>
          <button class="btn btn-outline-danger btn-sm"    onclick="deleteCol()">삭제</button>
        </div>
      </c:if>
    </div>
  </div>

  <!-- 영화 목록 — TMDB ID 기준으로 JS에서 포스터 로딩 -->
  <div class="movie-grid" id="movieGrid">
    <c:forEach var="mid" items="${movieIds}">
      <div class="movie-card" id="mc-${mid}"
           onclick="location.href='${ctp}/movie/detail/${mid}'">
        <img src="" alt="" data-tmdb="${mid}"
             onerror="this.src='https://via.placeholder.com/140x210?text=No+Image'">
        <button class="remove-btn" onclick="removeMovie(event, ${collection.collectionId}, ${mid})">×</button>
        <div class="movie-title" id="mt-${mid}">로딩중...</div>
      </div>
    </c:forEach>
  </div>

  <c:if test="${empty movieIds}">
    <div class="empty">아직 담긴 영화가 없습니다.</div>
  </c:if>
</div>

<script>
var ctp = '${ctp}';
var TMDB_IMG = 'https://image.tmdb.org/t/p/w300';

// 포스터 로딩
document.querySelectorAll('img[data-tmdb]').forEach(function(img) {
  var id = img.dataset.tmdb;
  fetch(ctp + '/movie/detail/' + id)
    .then(function(r) { return r.text(); })
    .catch(function() {});
  // TMDB API 직접 호출로 포스터만 가져오기
  var apiUrl = ctp + '/movie/api/' + id;
  fetch(apiUrl).then(r => r.json()).then(function(d) {
    if (d.posterPath) img.src = TMDB_IMG + d.posterPath;
    var titleEl = document.getElementById('mt-' + id);
    if (titleEl && d.title) titleEl.textContent = d.title;
  });
});

function removeMovie(e, collectionId, movieId) {
  e.stopPropagation();
  if (!confirm('이 영화를 컬렉션에서 제거하시겠습니까?')) return;
  $.post(ctp + '/collection/movie/toggle',
    { collectionId: collectionId, movieId: movieId },
    function(res) {
      if (res.status === 'removed') {
        document.getElementById('mc-' + movieId).remove();
      }
    }, 'json');
}

function deleteCol() {
  if (!confirm('컬렉션을 삭제하시겠습니까?')) return;
  $.post(ctp + '/collection/delete',
    { collectionId: ${collection.collectionId} },
    function(res) {
      if (res.status === 'ok') location.href = ctp + '/collection/list';
    }, 'json');
}

function openEdit() {
  // 간단한 prompt 방식 (필요시 모달로 교체)
  var title = prompt('컬렉션 제목', '${collection.title}');
  if (!title) return;
  $.post(ctp + '/collection/update',
    { collectionId: ${collection.collectionId}, title: title,
      description: '${collection.description}', isPublic: ${collection.isPublic} },
    function(res) {
      if (res.status === 'ok') location.reload();
    }, 'json');
}
</script>
</body>
</html>
