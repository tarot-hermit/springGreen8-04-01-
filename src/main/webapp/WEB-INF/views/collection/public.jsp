<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>공개 컬렉션</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background:#0f0f0f; color:#e0e0e0; }
    .page-wrap { max-width:960px; margin:0 auto; padding:40px 20px; }
    .page-title { font-size:1.6rem; font-weight:700; margin-bottom:24px; }
    .grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(260px,1fr)); gap:16px; }
    .col-card { background:#1a1a1a; border-radius:12px; padding:20px;
                border:1px solid rgba(255,255,255,0.06); cursor:pointer;
                transition:border-color .2s; }
    .col-card:hover { border-color:rgba(229,9,20,0.4); }
    .col-title  { font-size:1rem; font-weight:700; margin-bottom:4px; }
    .col-owner  { font-size:12px; color:#e50914; margin-bottom:6px; }
    .col-desc   { font-size:13px; color:#888; margin-bottom:12px;
                  white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .col-meta   { font-size:12px; color:#555; }
    .empty { text-align:center; padding:60px 0; color:#555; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>
<div class="page-wrap">
  <div class="d-flex justify-content-between align-items-center mb-0">
    <div class="page-title">공개 컬렉션</div>
    <c:if test="${not empty sessionScope.loginUser}">
      <a href="${ctp}/collection/list" class="btn btn-outline-secondary btn-sm">내 컬렉션</a>
    </c:if>
  </div>

  <div class="grid">
    <c:forEach var="c" items="${collections}">
    <div class="col-card" onclick="location.href='${ctp}/collection/detail/${c.collectionId}'">
      <div class="col-title">${c.title}</div>
      <div class="col-owner">by ${c.mid}</div>
      <div class="col-desc">${empty c.description ? '설명 없음' : c.description}</div>
      <div class="col-meta">🎬 ${c.movieCount}편</div>
    </div>
    </c:forEach>
  </div>

  <c:if test="${empty collections}">
    <div class="empty">공개된 컬렉션이 없습니다.</div>
  </c:if>
</div>
</body>
</html>
