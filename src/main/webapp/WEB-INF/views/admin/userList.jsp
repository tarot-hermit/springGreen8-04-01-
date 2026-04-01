<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>회원 관리</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
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
    .role-badge { padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; }
    .role-admin { background:rgba(52,208,88,0.15); color:#34d058; }
    .role-user { background:rgba(148,163,184,0.1); color:#94a3b8; }
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
      <li><a href="${ctp}/admin/users" class="active"><i class="fa fa-users"></i> 회원 관리</a></li>
      <li><a href="${ctp}/admin/reviews"><i class="fa fa-star"></i> 리뷰 관리</a></li>
      <li><a href="${ctp}/"><i class="fa fa-home"></i> 사이트로</a></li>
    </ul>
  </div>

  <div class="main-area">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div class="page-title mb-0">회원 관리 <span style="font-size:1rem;color:#64748b;font-weight:400;">(${users.size()}명)</span></div>
      <input type="text" id="searchInput" placeholder="아이디 / 이름 검색..." oninput="filterTable()" style="width:220px;">
    </div>

    <div class="table-dark-custom">
      <table class="table table-borderless mb-0" id="userTable">
        <thead>
          <tr>
            <th>No</th>
            <th>아이디</th>
            <th>이름</th>
            <th>이메일</th>
            <th>역할</th>
            <th>가입일</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="u" items="${users}" varStatus="st">
          <tr id="row-${u.userNo}">
            <td style="color:#475569;">${st.index+1}</td>
            <td style="font-weight:600;">${u.userId}</td>
            <td>${u.userName}</td>
            <td style="color:#64748b;">${u.userEmail}</td>
            <td>
              <span class="role-badge ${u.userRole == 'ADMIN' ? 'role-admin' : 'role-user'}">
                ${u.userRole}
              </span>
            </td>
            <td style="color:#475569;">${u.joinDate}</td>
            <td>
              <c:if test="${u.userRole != 'ADMIN'}">
                <button class="btn btn-sm btn-outline-success me-1"
                        onclick="changeRole(${u.userNo}, 'ADMIN')">관리자↑</button>
              </c:if>
              <c:if test="${u.userRole == 'ADMIN'}">
                <button class="btn btn-sm btn-outline-secondary me-1"
                        onclick="changeRole(${u.userNo}, 'USER')">일반↓</button>
              </c:if>
              <button class="btn btn-sm btn-outline-danger"
                      onclick="deleteUser(${u.userNo})">탈퇴</button>
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
    document.querySelectorAll('#userTable tbody tr').forEach(function(row) {
        row.style.display = row.innerText.toLowerCase().includes(kw) ? '' : 'none';
    });
}

function changeRole(userNo, role) {
    if (!confirm(role + ' 권한으로 변경하시겠습니까?')) return;
    $.post(ctp + '/admin/user/role', { userNo: userNo, userRole: role }, function(res) {
        if (res == 'ok') { alert('변경되었습니다.'); location.reload(); }
        else alert('실패했습니다.');
    });
}

function deleteUser(userNo) {
    if (!confirm('해당 회원을 강제 탈퇴시키겠습니까?\n관련 데이터가 삭제될 수 있습니다.')) return;
    $.post(ctp + '/admin/user/delete', { userNo: userNo }, function(res) {
        if (res == 'ok') { $('#row-' + userNo).remove(); alert('탈퇴처리 완료'); }
        else alert('실패했습니다.');
    });
}
</script>
</body>
</html>