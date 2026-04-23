<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>신고 관리</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <%@ include file="/WEB-INF/views/admin/adminSwal.jspf" %>
  <style>
    body { background:#0f172a; color:#fff; }
    .sidebar { width:220px; background:#1e293b; padding:24px 0; flex-shrink:0; position:fixed; top:0; left:0; height:100vh; z-index:100; }
    .sidebar-logo { font-size:1.1rem; font-weight:800; color:#34d058; padding:0 24px 24px; border-bottom:1px solid rgba(255,255,255,0.08); }
    .sidebar-menu { list-style:none; padding:16px 0; margin:0; }
    .sidebar-menu li a { display:flex; align-items:center; gap:10px; padding:12px 24px; color:#94a3b8; text-decoration:none; font-size:14px; transition:all 0.15s; }
    .sidebar-menu li a:hover, .sidebar-menu li a.active { background:rgba(52,208,88,0.1); color:#34d058; }
    .admin-wrap { display:flex; min-height:100vh; }
    .main-area { margin-left:220px; padding:32px; flex:1; }
    .page-title { font-size:1.4rem; font-weight:700; margin-bottom:24px; }
    .table-dark-custom { background:#1e293b; border-radius:16px; overflow:hidden; border:1px solid rgba(255,255,255,0.06); }
    .table-dark-custom table { margin:0; color:#fff; }
    .table-dark-custom th { background:#0f172a; color:#64748b; font-size:13px; font-weight:600; padding:14px 16px; border-bottom:1px solid rgba(255,255,255,0.06); }
    .table-dark-custom td { padding:13px 16px; border-bottom:1px solid rgba(255,255,255,0.04); vertical-align:middle; font-size:14px; }
    .status-badge { padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; }
    .status-PENDING { background:rgba(251,191,36,0.15); color:#fbbf24; }
    .status-PROCESSED { background:rgba(52,208,88,0.15); color:#34d058; }
    .status-REJECTED { background:rgba(148,163,184,0.1); color:#94a3b8; }
    .type-badge { padding:3px 8px; border-radius:6px; font-size:11px; background:rgba(96,165,250,0.1); color:#60a5fa; }
    .reason-cell { max-width:220px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
    .movie-link { color:#60a5fa; text-decoration:none; }
    .movie-link:hover { text-decoration:underline; }
    input[type=text] { background:#0f172a; border:1px solid rgba(255,255,255,0.1); color:#fff; border-radius:8px; padding:8px 14px; }
    input[type=text]::placeholder { color:#475569; }
  </style>
</head>
<body>
<div class="admin-wrap">
  <div class="sidebar">
    <div class="sidebar-logo"><i class="fa fa-film me-2"></i>관리자</div>
    <ul class="sidebar-menu">
      <li><a href="${ctp}/admin/dashboard"><i class="fa fa-bar-chart"></i> 대시보드</a></li>
      <li><a href="${ctp}/admin/users"><i class="fa fa-users"></i> 회원 관리</a></li>
      <li><a href="${ctp}/admin/reviews"><i class="fa fa-star"></i> 리뷰 관리</a></li>
      <li><a href="${ctp}/admin/reports" class="active"><i class="fa fa-flag"></i> 신고 관리</a></li>
      <li><a href="${ctp}/"><i class="fa fa-home"></i> 사이트로</a></li>
    </ul>
  </div>

  <div class="main-area">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div class="page-title mb-0">
        신고 관리 <span style="font-size:1rem;color:#64748b;font-weight:400;">(${reports.size()}건)</span>
      </div>
      <input type="text" id="searchInput" placeholder="신고자 / 사유 / 영화 검색..." oninput="filterTable()" style="width:260px;">
    </div>

    <div class="table-dark-custom">
      <table class="table table-borderless mb-0" id="reportTable">
        <thead>
          <tr>
            <th>No</th>
            <th>유형</th>
            <th>신고자</th>
            <th>대상 ID</th>
            <th>영화</th>
            <th>사유</th>
            <th>상태</th>
            <th>신고일</th>
            <th>처리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${reports}" varStatus="st">
            <tr id="row-${r.reportId}">
              <td style="color:#475569;">${st.index+1}</td>
              <td><span class="type-badge">${r.targetType}</span></td>
              <td style="font-weight:600;">${fn:escapeXml(r.reporterMid)}</td>
              <td style="color:#64748b;">${r.targetId}</td>
              <td>
                <c:choose>
                  <c:when test="${r.targetType == 'REVIEW' && r.tmdbId > 0}">
                    <a href="${ctp}/movie/detail/${r.tmdbId}" class="movie-link" title="${fn:escapeXml(r.movieTitle)}">
                      <c:choose>
                        <c:when test="${empty r.movieTitle}">${r.tmdbId}</c:when>
                        <c:otherwise>${fn:escapeXml(r.movieTitle)}</c:otherwise>
                      </c:choose>
                    </a>
                  </c:when>
                  <c:otherwise>
                    <span style="color:#475569;">-</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td class="reason-cell" title="${fn:escapeXml(r.reason)}">${fn:escapeXml(r.reason)}</td>
              <td>
                <span class="status-badge status-${r.status}">${r.status}</span>
              </td>
              <td style="color:#475569;"><fmt:formatDate value="${r.regDate}" pattern="yyyy년 MM월 dd일 HH:mm:ss"/></td>
              <td>
                <c:if test="${r.status == 'PENDING'}">
                  <button class="btn btn-sm btn-outline-success me-1"
                          onclick="updateStatus(${r.reportId}, 'PROCESSED')">처리</button>
                  <button class="btn btn-sm btn-outline-secondary"
                          onclick="updateStatus(${r.reportId}, 'REJECTED')">기각</button>
                </c:if>
                <c:if test="${r.status != 'PENDING'}">
                  <span style="color:#475569;font-size:12px;">완료</span>
                </c:if>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
var ctp = '${ctp}';

function filterTable() {
    var kw = document.getElementById('searchInput').value.toLowerCase();
    document.querySelectorAll('#reportTable tbody tr').forEach(function(row) {
        row.style.display = row.innerText.toLowerCase().includes(kw) ? '' : 'none';
    });
}

function updateStatus(reportId, status) {
    var isProcessed = status === 'PROCESSED';
    adminConfirm({
        title: isProcessed ? '\uC2E0\uACE0 \uCC98\uB9AC' : '\uC2E0\uACE0 \uAE30\uAC01',
        text: isProcessed
            ? '\uC2E0\uACE0\uB97C \uCC98\uB9AC\uD558\uC2DC\uACA0\uC2B5\uB2C8\uAE4C? \uB9AC\uBDF0 \uC2E0\uACE0\uB294 \uBE14\uB77C\uC778\uB4DC \uBB38\uAD6C\uB85C \uBCC0\uACBD\uB429\uB2C8\uB2E4.'
            : '\uC774 \uC2E0\uACE0\uB97C \uAE30\uAC01 \uCC98\uB9AC\uD558\uC2DC\uACA0\uC2B5\uB2C8\uAE4C?',
        confirmButtonText: isProcessed ? '\uCC98\uB9AC' : '\uAE30\uAC01'
    }).then(function(result) {
        if (!result.isConfirmed) return;

        $.post(ctp + '/admin/report/status', { reportId: reportId, status: status }, function(res) {
            if (res === 'ok') {
                adminToast('success', isProcessed ? '\uC2E0\uACE0\uB97C \uCC98\uB9AC\uD588\uC2B5\uB2C8\uB2E4.' : '\uC2E0\uACE0\uB97C \uAE30\uAC01\uD588\uC2B5\uB2C8\uB2E4.').then(function() {
                    location.reload();
                });
            }
            else {
                adminAlert('error', '\uCC98\uB9AC \uC2E4\uD328', '\uC2E0\uACE0 \uCC98\uB9AC\uC5D0 \uC2E4\uD328\uD588\uC2B5\uB2C8\uB2E4.');
            }
        }).fail(function() {
            adminAlert('error', '\uC694\uCCAD \uC2E4\uD328', '\uC2E0\uACE0 \uCC98\uB9AC \uC694\uCCAD\uC744 \uCC98\uB9AC\uD558\uC9C0 \uBABB\uD588\uC2B5\uB2C8\uB2E4.');
        });
    });
}
</script>
</body>
</html>
