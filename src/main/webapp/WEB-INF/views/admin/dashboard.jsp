<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>관리자 대시보드</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background:#0f172a; color:#fff; }
    .admin-wrap { display:flex; min-height:100vh; }
    .sidebar {
      width:220px; background:#1e293b; padding:24px 0;
      flex-shrink:0; position:fixed; top:0; left:0;
      height:100vh; z-index:100;
    }
    .sidebar-logo {
      font-size:1.1rem; font-weight:800; color:#34d058;
      padding:0 24px 24px; border-bottom:1px solid rgba(255,255,255,0.08);
    }
    .sidebar-menu { list-style:none; padding:16px 0; margin:0; }
    .sidebar-menu li a {
      display:flex; align-items:center; gap:10px;
      padding:12px 24px; color:#94a3b8;
      text-decoration:none; font-size:14px;
      transition:all 0.15s;
    }
    .sidebar-menu li a:hover,
    .sidebar-menu li a.active {
      background:rgba(52,208,88,0.1); color:#34d058;
    }
    .main-area { margin-left:220px; padding:32px; flex:1; }
    .stat-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:16px; margin-bottom:32px; }
    .stat-card {
      background:#1e293b; border-radius:16px;
      padding:24px; border:1px solid rgba(255,255,255,0.06);
    }
    .stat-label { font-size:13px; color:#64748b; margin-bottom:8px; }
    .stat-value { font-size:2rem; font-weight:800; }
    .c-green { color:#34d058; }
    .c-blue { color:#60a5fa; }
    .c-amber { color:#fbbf24; }
    .c-pink { color:#f472b6; }
    .page-title { font-size:1.4rem; font-weight:700; margin-bottom:24px; }
  </style>
</head>
<body>
<div class="admin-wrap">
  <div class="sidebar">
    <div class="sidebar-logo"><i class="fa fa-film me-2"></i>관리자</div>
    <ul class="sidebar-menu">
      <li><a href="${ctp}/admin/dashboard" class="active"><i class="fa fa-bar-chart"></i> 대시보드</a></li>
      <li><a href="${ctp}/admin/users"><i class="fa fa-users"></i> 회원 관리</a></li>
      <li><a href="${ctp}/admin/reviews"><i class="fa fa-star"></i> 리뷰 관리</a></li>
      <li><a href="${ctp}/"><i class="fa fa-home"></i> 사이트로</a></li>
    </ul>
  </div>

  <div class="main-area">
    <div class="page-title">대시보드</div>
    <div class="stat-grid">
      <div class="stat-card">
        <div class="stat-label">전체 회원</div>
        <div class="stat-value c-green">${stats.userCnt}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">전체 리뷰</div>
        <div class="stat-value c-blue">${stats.reviewCnt}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">전체 댓글</div>
        <div class="stat-value c-amber">${stats.commentCnt}</div>
      </div>
      <div class="stat-card">
        <div class="stat-label">찜 목록</div>
        <div class="stat-value c-pink">${stats.watchCnt}</div>
      </div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;">
      <div style="background:#1e293b;border-radius:16px;padding:24px;border:1px solid rgba(255,255,255,0.06);">
        <div style="font-weight:700;margin-bottom:16px;">빠른 이동</div>
        <a href="${ctp}/admin/users" class="btn btn-outline-success w-100 mb-2">
          <i class="fa fa-users me-2"></i>회원 관리
        </a>
        <a href="${ctp}/admin/reviews" class="btn btn-outline-primary w-100">
          <i class="fa fa-star me-2"></i>리뷰 관리
        </a>
      </div>
    </div>
  </div>
</div>
</body>
</html>