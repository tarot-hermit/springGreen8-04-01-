<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>관리자 대시보드</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <%@ include file="/WEB-INF/views/admin/adminSwal.jspf" %>
  <style>
    body { background:#0f172a; color:#fff; }
    .admin-wrap { display:flex; min-height:100vh; }
    .sidebar {
      width:220px;
      background:#1e293b;
      padding:24px 0;
      flex-shrink:0;
      position:fixed;
      top:0;
      left:0;
      height:100vh;
      z-index:100;
    }
    .sidebar-logo {
      font-size:1.1rem;
      font-weight:800;
      color:#34d058;
      padding:0 24px 24px;
      border-bottom:1px solid rgba(255,255,255,0.08);
    }
    .sidebar-menu { list-style:none; padding:16px 0; margin:0; }
    .sidebar-menu li a {
      display:flex;
      align-items:center;
      gap:10px;
      padding:12px 24px;
      color:#94a3b8;
      text-decoration:none;
      font-size:14px;
      transition:all 0.15s;
    }
    .sidebar-menu li a:hover,
    .sidebar-menu li a.active {
      background:rgba(52,208,88,0.1);
      color:#34d058;
    }
    .main-area {
      margin-left:220px;
      padding:32px;
      flex:1;
    }
    .page-title {
      font-size:1.5rem;
      font-weight:700;
      margin-bottom:8px;
    }
    .page-subtitle {
      color:#94a3b8;
      font-size:14px;
      margin-bottom:24px;
    }
    .stat-grid {
      display:grid;
      grid-template-columns:repeat(auto-fit, minmax(200px, 1fr));
      gap:16px;
      margin-bottom:28px;
    }
    .stat-card {
      background:#1e293b;
      border-radius:16px;
      padding:24px;
      border:1px solid rgba(255,255,255,0.06);
      box-shadow:0 10px 30px rgba(0,0,0,0.18);
    }
    .stat-label {
      font-size:13px;
      color:#64748b;
      margin-bottom:8px;
    }
    .stat-value {
      font-size:2rem;
      font-weight:800;
      line-height:1;
    }
    .c-green { color:#34d058; }
    .c-blue  { color:#60a5fa; }
    .c-amber { color:#fbbf24; }
    .c-pink  { color:#f472b6; }
    .c-red   { color:#f87171; }
    .content-grid {
      display:grid;
      grid-template-columns:1fr 1fr;
      gap:16px;
      align-items:start;
    }
    .panel-card {
      background:#1e293b;
      border-radius:16px;
      padding:24px;
      border:1px solid rgba(255,255,255,0.06);
      box-shadow:0 10px 30px rgba(0,0,0,0.18);
      position:relative;
      overflow:hidden;
    }
    .panel-header {
      display:flex;
      align-items:flex-start;
      justify-content:space-between;
      gap:12px;
      margin-bottom:18px;
    }
    .panel-copy {
      min-width:0;
    }
    .panel-title {
      font-size:1rem;
      font-weight:700;
      margin-bottom:6px;
    }
    .panel-desc {
      color:#94a3b8;
      font-size:13px;
      margin:0;
      line-height:1.6;
    }
    .panel-badge {
      display:inline-flex;
      align-items:center;
      justify-content:center;
      padding:6px 10px;
      border-radius:999px;
      background:rgba(52,208,88,0.12);
      border:1px solid rgba(52,208,88,0.2);
      color:#86efac;
      font-size:12px;
      font-weight:700;
      white-space:nowrap;
    }
    .quick-link {
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:12px;
      width:100%;
      margin-bottom:10px;
      border-radius:12px;
    }
    .quick-link:last-child {
      margin-bottom:0;
    }
    .keyword-list {
      display:flex;
      flex-direction:column;
      gap:10px;
    }
    .keyword-item {
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:14px;
      padding:14px 16px;
      border-radius:14px;
      background:rgba(15,23,42,0.55);
      border:1px solid rgba(255,255,255,0.06);
      transition:transform 0.15s ease, border-color 0.15s ease, background 0.15s ease;
    }
    .keyword-item:hover {
      transform:translateY(-1px);
      border-color:rgba(96,165,250,0.28);
      background:rgba(15,23,42,0.8);
    }
    .keyword-main {
      display:flex;
      align-items:center;
      gap:12px;
      min-width:0;
      flex:1;
    }
    .keyword-rank {
      width:34px;
      height:34px;
      border-radius:10px;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      font-size:13px;
      font-weight:800;
      background:rgba(255,255,255,0.05);
      color:#94a3b8;
      flex-shrink:0;
    }
    .keyword-rank.top-rank {
      background:rgba(251,191,36,0.16);
      color:#fbbf24;
    }
    .keyword-info {
      min-width:0;
      display:flex;
      flex-direction:column;
      gap:4px;
    }
    .keyword-name {
      display:inline-flex;
      align-items:center;
      gap:8px;
      min-width:0;
      color:#e2e8f0;
      text-decoration:none;
      font-weight:600;
    }
    .keyword-name i {
      color:#34d058;
      font-size:12px;
      flex-shrink:0;
    }
    .keyword-name span {
      overflow:hidden;
      text-overflow:ellipsis;
      white-space:nowrap;
    }
    .keyword-name:hover {
      color:#93c5fd;
    }
    .keyword-subtext {
      color:#64748b;
      font-size:12px;
    }
    .keyword-count {
      padding:7px 12px;
      border-radius:999px;
      background:rgba(96,165,250,0.12);
      border:1px solid rgba(96,165,250,0.18);
      color:#bfdbfe;
      font-size:12px;
      font-weight:700;
      white-space:nowrap;
      flex-shrink:0;
    }
    .noti-dot {
      display:inline-block;
      width:8px;
      height:8px;
      background:#f87171;
      border-radius:50%;
      margin-left:4px;
      vertical-align:middle;
    }
    .empty-text {
      color:#64748b;
      font-size:13px;
      margin:0;
    }
    @media (max-width: 991px) {
      .sidebar {
        position:static;
        width:100%;
        height:auto;
      }
      .admin-wrap {
        display:block;
      }
      .main-area {
        margin-left:0;
        padding:20px;
      }
      .content-grid {
        grid-template-columns:1fr;
      }
    }
  </style>
</head>
<body>
<div class="admin-wrap">
  <div class="sidebar">
    <div class="sidebar-logo"><i class="fa fa-film me-2"></i>관리자</div>
    <ul class="sidebar-menu">
      <li><a href="${ctp}/admin/dashboard" class="active"><i class="fa fa-bar-chart"></i>대시보드</a></li>
      <li><a href="${ctp}/admin/users"><i class="fa fa-users"></i>회원 관리</a></li>
      <li><a href="${ctp}/admin/reviews"><i class="fa fa-star"></i>리뷰 관리</a></li>
      <li>
        <a href="${ctp}/admin/reports">
          <i class="fa fa-flag"></i>신고 관리
          <c:if test="${pendingReportCnt > 0}">
            <span class="noti-dot"></span>
          </c:if>
        </a>
      </li>
      <li><a href="${ctp}/"><i class="fa fa-home"></i>메인으로</a></li>
    </ul>
  </div>

  <div class="main-area">
    <div class="page-title">대시보드</div>
    <div class="page-subtitle">서비스 운영 현황과 최근 검색 데이터를 한눈에 확인할 수 있습니다.</div>

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
      <div class="stat-card">
        <div class="stat-label">미처리 신고</div>
        <div class="stat-value c-red">${stats.pendingReportCnt}</div>
      </div>
    </div>

    <div class="content-grid">
      <div class="panel-card">
        <div class="panel-header">
          <div class="panel-copy">
            <div class="panel-title">빠른 이동</div>
            <div class="panel-desc">관리 기능으로 빠르게 이동할 수 있습니다.</div>
          </div>
          <div class="panel-badge">Admin</div>
        </div>
        <a href="${ctp}/admin/users" class="btn btn-outline-success quick-link">
          <span><i class="fa fa-users me-2"></i>회원 관리</span>
          <i class="fa fa-angle-right"></i>
        </a>
        <a href="${ctp}/admin/reviews" class="btn btn-outline-primary quick-link">
          <span><i class="fa fa-star me-2"></i>리뷰 관리</span>
          <i class="fa fa-angle-right"></i>
        </a>
        <a href="${ctp}/admin/reports" class="btn btn-outline-danger quick-link">
          <span><i class="fa fa-flag me-2"></i>신고 관리</span>
          <i class="fa fa-angle-right"></i>
        </a>
      </div>

      <div class="panel-card">
        <div class="panel-header">
          <div class="panel-copy">
            <div class="panel-title">인기 검색어 TOP 10</div>
            <div class="panel-desc">사용자 검색 흐름을 기준으로 집계된 최근 인기 키워드입니다.</div>
          </div>
          <div class="panel-badge">Trending</div>
        </div>
        <c:choose>
          <c:when test="${not empty popularKeywords}">
            <div class="keyword-list">
              <c:forEach var="kw" items="${popularKeywords}" varStatus="st">
                <c:url var="keywordSearchUrl" value="/movie/search">
                  <c:param name="q" value="${kw.keyword}"/>
                </c:url>
                <div class="keyword-item">
                  <div class="keyword-main">
                    <div class="keyword-rank ${st.index < 3 ? 'top-rank' : ''}">${st.index + 1}</div>
                    <div class="keyword-info">
                      <a href="${keywordSearchUrl}" class="keyword-name">
                        <i class="fa fa-search"></i>
                        <span>${kw.keyword}</span>
                      </a>
                      <div class="keyword-subtext">최근 검색 트렌드에서 많이 조회된 키워드</div>
                    </div>
                  </div>
                  <div class="keyword-count">${kw.searchCnt}회</div>
                </div>
              </c:forEach>
            </div>
          </c:when>
          <c:otherwise>
            <p class="empty-text">검색 기록이 아직 없습니다.</p>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>

