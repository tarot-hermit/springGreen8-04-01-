<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>내 컬렉션</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background:#0f0f0f; color:#e0e0e0; }
    .page-wrap { max-width:960px; margin:0 auto; padding:40px 20px; }
    .page-title { font-size:1.6rem; font-weight:700; margin-bottom:8px; }
    .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:16px; margin-top:24px; }
    .col-card { background:#1a1a1a; border-radius:12px; padding:20px;
                border:1px solid rgba(255,255,255,0.06); cursor:pointer;
                transition:border-color .2s; }
    .col-card:hover { border-color:rgba(229,9,20,0.4); }
    .col-title { font-size:1rem; font-weight:700; margin-bottom:6px; }
    .col-desc  { font-size:13px; color:#888; margin-bottom:12px;
                 white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .col-meta  { font-size:12px; color:#555; display:flex; gap:12px; }
    .badge-pub { background:rgba(52,208,88,0.15); color:#34d058;
                 padding:2px 8px; border-radius:999px; font-size:11px; }
    .badge-pri { background:rgba(148,163,184,0.1); color:#888;
                 padding:2px 8px; border-radius:999px; font-size:11px; }
    .empty { text-align:center; padding:60px 0; color:#555; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>
<div class="page-wrap">
  <div class="d-flex justify-content-between align-items-center">
    <div class="page-title">내 컬렉션</div>
    <button class="btn btn-danger btn-sm" onclick="openCreate()">+ 새 컬렉션</button>
  </div>

  <div class="grid">
    <c:forEach var="c" items="${collections}">
    <div class="col-card" onclick="location.href='${ctp}/collection/detail/${c.collectionId}'">
      <div class="d-flex justify-content-between align-items-start mb-1">
        <div class="col-title">${c.title}</div>
        <span class="${c.isPublic == 1 ? 'badge-pub' : 'badge-pri'}">
          ${c.isPublic == 1 ? '공개' : '비공개'}
        </span>
      </div>
      <div class="col-desc">${empty c.description ? '설명 없음' : c.description}</div>
      <div class="col-meta">
        <span>🎬 ${c.movieCount}편</span>
      </div>
    </div>
    </c:forEach>
  </div>

  <c:if test="${empty collections}">
    <div class="empty">아직 컬렉션이 없습니다.<br>새 컬렉션을 만들어보세요!</div>
  </c:if>
</div>

<!-- 컬렉션 생성 모달 -->
<div class="modal fade" id="createModal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content bg-dark text-white">
      <div class="modal-header border-secondary">
        <h5 class="modal-title">새 컬렉션 만들기</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="mb-3">
          <label class="form-label">제목 <span class="text-danger">*</span></label>
          <input type="text" id="colTitle" class="form-control bg-dark text-white border-secondary"
                 placeholder="컬렉션 이름" maxlength="100">
        </div>
        <div class="mb-3">
          <label class="form-label">설명</label>
          <textarea id="colDesc" class="form-control bg-dark text-white border-secondary"
                    rows="3" placeholder="컬렉션 설명 (선택)" maxlength="500"></textarea>
        </div>
        <div class="form-check">
          <input class="form-check-input" type="checkbox" id="colPublic" checked>
          <label class="form-check-label" for="colPublic">공개 컬렉션</label>
        </div>
      </div>
      <div class="modal-footer border-secondary">
        <button class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
        <button class="btn btn-danger" onclick="createCollection()">만들기</button>
      </div>
    </div>
  </div>
</div>

<script>
var ctp = '${ctp}';
function openCreate() {
  new bootstrap.Modal(document.getElementById('createModal')).show();
}
function createCollection() {
  var title    = document.getElementById('colTitle').value.trim();
  var desc     = document.getElementById('colDesc').value.trim();
  var isPublic = document.getElementById('colPublic').checked ? 1 : 0;
  if (!title) { alert('제목을 입력해주세요.'); return; }
  $.post(ctp + '/collection/create',
    { title: title, description: desc, isPublic: isPublic },
    function(res) {
      if (res.status === 'ok') { location.reload(); }
      else alert('생성에 실패했습니다.');
    }, 'json');
}
</script>
</body>
</html>
