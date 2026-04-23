<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>회원 관리</title>
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
    .role-badge { padding:4px 10px; border-radius:999px; font-size:11px; font-weight:700; }
    .role-admin { background:rgba(52,208,88,0.15); color:#34d058; }
    .role-user  { background:rgba(148,163,184,0.1); color:#94a3b8; }
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
      <li><a href="${ctp}/admin/reports"><i class="fa fa-flag"></i> 신고 관리</a></li>
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
            <th>닉네임</th>
            <th>이메일</th>
            <th>등급</th>
            <th>가입일</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="u" items="${users}" varStatus="st">
          <tr id="row-${u.userNo}">
            <td style="color:#475569;">${st.index+1}</td>
            <td style="font-weight:600;">${fn:escapeXml(u.userId)}</td>
            <td>${fn:escapeXml(u.userName)}</td>
            <td style="color:#64748b;">${fn:escapeXml(u.userEmail)}</td>
            <td>
              <span class="role-badge ${u.userRole == 'ADMIN' ? 'role-admin' : 'role-user'}">
                ${u.userRole}
              </span>
            </td>
            <td style="color:#475569;">
              <fmt:formatDate value="${u.joinDate}" pattern="yyyy년 MM월 dd일 HH:mm:ss"/>
            </td>
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

function changeRole(userNo, userRole) {
    var roleLabel = userRole === 'ADMIN' ? '\uAD00\uB9AC\uC790' : '\uC77C\uBC18 \uD68C\uC6D0';
    adminConfirm({
        title: '\uAD8C\uD55C \uBCC0\uACBD',
        text: roleLabel + ' \uAD8C\uD55C\uC73C\uB85C \uBCC0\uACBD\uD558\uC2DC\uACA0\uC2B5\uB2C8\uAE4C?',
        confirmButtonText: '\uBCC0\uACBD'
    }).then(function(result) {
        if (!result.isConfirmed) return;

        $.post(ctp + '/admin/user/role', { userNo: userNo, userRole: userRole }, function(res) {
            var status = typeof res === 'string' ? res : (res && res.status ? res.status : '');
            if (status === 'ok') {
                adminToast('success', '\uAD8C\uD55C\uC774 \uBCC0\uACBD\uB418\uC5C8\uC2B5\uB2C8\uB2E4.').then(function() {
                    location.reload();
                });
            }
            else if (status === 'self_downgraded') {
                adminAlert('info', '\uAD8C\uD55C \uD574\uC81C\uB428', '\uAD00\uB9AC\uC790 \uAD8C\uD55C\uC774 \uD574\uC81C\uB418\uC5B4 \uBA54\uC778 \uD398\uC774\uC9C0\uB85C \uC774\uB3D9\uD569\uB2C8\uB2E4.').then(function() {
                    location.href = ctp + '/';
                });
            }
            else if (status === 'forbidden') {
                adminAlert('error', '\uAD8C\uD55C \uC5C6\uC74C', '\uAD00\uB9AC\uC790 \uAD8C\uD55C\uC774 \uC5C6\uC2B5\uB2C8\uB2E4.').then(function() {
                    location.href = ctp + '/';
                });
            }
            else if (status === 'login') {
                adminAlert('info', '\uB85C\uADF8\uC778 \uD544\uC694', '\uB85C\uADF8\uC778\uC774 \uD544\uC694\uD569\uB2C8\uB2E4.').then(function() {
                    location.href = ctp + '/user/login';
                });
            }
            else {
                adminAlert('error', '\uBCC0\uACBD \uC2E4\uD328', '\uAD8C\uD55C \uBCC0\uACBD\uC5D0 \uC2E4\uD328\uD588\uC2B5\uB2C8\uB2E4.');
            }
        }).fail(function() {
            adminAlert('error', '\uC694\uCCAD \uC2E4\uD328', '\uAD8C\uD55C \uBCC0\uACBD \uC694\uCCAD\uC744 \uCC98\uB9AC\uD558\uC9C0 \uBABB\uD588\uC2B5\uB2C8\uB2E4.');
        });
    });
}

function deleteUser(userNo) {
    adminDangerConfirm({
        title: '\uD68C\uC6D0 \uAC15\uC81C \uD0C8\uD1F4',
        text: '\uD574\uB2F9 \uD68C\uC6D0\uC744 \uAC15\uC81C \uD0C8\uD1F4\uC2DC\uD0A4\uACA0\uC2B5\uB2C8\uAE4C? \uAD00\uB828 \uB370\uC774\uD130\uAC00 \uD568\uAED8 \uC0AD\uC81C\uB420 \uC218 \uC788\uC2B5\uB2C8\uB2E4.',
        confirmButtonText: '\uD0C8\uD1F4 \uCC98\uB9AC'
    }).then(function(result) {
        if (!result.isConfirmed) return;

        $.post(ctp + '/admin/user/delete', { userNo: userNo }, function(res) {
            if (res === 'ok') {
                $('#row-' + userNo).remove();
                adminToast('success', '\uD0C8\uD1F4 \uCC98\uB9AC\uAC00 \uC644\uB8CC\uB418\uC5C8\uC2B5\uB2C8\uB2E4.');
            }
            else {
                adminAlert('error', '\uCC98\uB9AC \uC2E4\uD328', '\uD68C\uC6D0 \uD0C8\uD1F4 \uCC98\uB9AC\uC5D0 \uC2E4\uD328\uD588\uC2B5\uB2C8\uB2E4.');
            }
        }).fail(function() {
            adminAlert('error', '\uC694\uCCAD \uC2E4\uD328', '\uD68C\uC6D0 \uD0C8\uD1F4 \uC694\uCCAD\uC744 \uCC98\uB9AC\uD558\uC9C0 \uBABB\uD588\uC2B5\uB2C8\uB2E4.');
        });
    });
}
</script>
</body>
</html>
