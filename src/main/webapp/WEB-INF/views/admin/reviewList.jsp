<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>리뷰 관리</title>
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
    .content-cell { max-width:280px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
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
      <li><a href="${ctp}/admin/reviews" class="active"><i class="fa fa-star"></i> 리뷰 관리</a></li>
      <li><a href="${ctp}/admin/reports"><i class="fa fa-flag"></i> 신고 관리</a></li>
      <li><a href="${ctp}/"><i class="fa fa-home"></i> 사이트로</a></li>
    </ul>
  </div>

  <div class="main-area">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div class="page-title mb-0">리뷰 관리 <span style="font-size:1rem;color:#64748b;font-weight:400;">(${reviews.size()}건)</span></div>
      <input type="text" id="searchInput" placeholder="작성자 / 내용 검색..." oninput="filterTable()" style="width:220px;">
    </div>

    <div class="table-dark-custom">
      <table class="table table-borderless mb-0" id="reviewTable">
        <thead>
          <tr>
            <th>No</th>
            <th>영화ID</th>
            <th>작성자</th>
            <th>별점</th>
            <th>내용</th>
            <th>공감</th>
            <th>작성일</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach var="r" items="${reviews}" varStatus="st">
          <tr id="row-${r.reviewNo}">
            <td style="color:#475569;">${st.index+1}</td>
            <td>
              <a href="${ctp}/movie/detail/${r.movieNo}"
                 style="color:#60a5fa;text-decoration:none;font-weight:600;">
                ${r.movieNo}
              </a>
            </td>
            <td>${r.userNo}</td>
            <td class="text-warning fw-bold">${r.rating}★</td>
            <td class="content-cell" title="${r.content}">${r.content}</td>
            <td style="color:#64748b;">${r.likeCnt}</td>
            <td style="color:#475569;">${r.regDate}</td>
            <td>
              <button class="btn btn-sm btn-outline-danger"
                      onclick="deleteReview(${r.reviewNo})">삭제</button>
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
    document.querySelectorAll('#reviewTable tbody tr').forEach(function(row) {
        row.style.display = row.innerText.toLowerCase().includes(kw) ? '' : 'none';
    });
}

function deleteReview(reviewNo) {
    if (!confirm('해당 리뷰를 삭제하시겠습니까?')) return;
    $.post(ctp + '/admin/review/delete', { reviewId: reviewNo }, function(res) {
        if (res === 'ok') { $('#row-' + reviewNo).remove(); }
        else alert('실패했습니다.');
    });
}
</script>
</body>
</html>
