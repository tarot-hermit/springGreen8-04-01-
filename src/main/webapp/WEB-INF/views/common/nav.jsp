<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold text-success" href="${ctp}/">
      <i class="fa fa-film"></i> SpringGreen8
    </a>
    <button class="navbar-toggler" type="button"
            data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="navbarNav">
      <!-- 왼쪽 메뉴 -->
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link" href="${ctp}/movie/list">영화</a>
        </li>
        <li class="nav-item dropdown">
          <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">장르</a>
          <ul class="dropdown-menu dropdown-menu-dark">
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=28&genreName=액션">액션</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=18&genreName=드라마">드라마</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=35&genreName=코미디">코미디</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=27&genreName=공포">공포</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=10749&genreName=로맨스">로맨스</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=878&genreName=SF">SF</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=53&genreName=스릴러">스릴러</a></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre?genreId=16&genreName=애니메이션">애니메이션</a></li>
            <li><hr class="dropdown-divider"></li>
            <li><a class="dropdown-item" href="${ctp}/movie/genre">전체 장르 보기</a></li>
          </ul>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${ctp}/movie/trending">🔥 트렌딩</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${ctp}/movie/upcoming">🎬 개봉예정</a>
        </li>
      </ul>

      <!-- 검색창 -->
      <form class="d-flex mx-auto" style="width:350px;"
            action="${ctp}/movie/search" method="get">
        <div class="input-group">
          <input type="text" class="form-control bg-secondary text-white border-0"
                 name="q" id="navSearch" placeholder="영화 검색..."
                 autocomplete="off" value="${param.q}">
          <button type="submit" class="btn btn-success">
            <i class="fa fa-search"></i>
          </button>
        </div>
      </form>

      <!-- 오른쪽 메뉴 -->
      <ul class="navbar-nav ms-auto align-items-center">
        <c:choose>
          <c:when test="${empty sessionScope.loginUser}">
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/login">로그인</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/join">회원가입</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/collection/public">컬렉션</a>
            </li>
          </c:when>
          <c:otherwise>
            <!-- 마이페이지 -->
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/mypage">
                <i class="fa fa-user"></i> ${sessionScope.loginUser.userName}
              </a>
            </li>

            <!-- 알림 드롭다운 -->
            <li class="nav-item dropdown">
              <a class="nav-link position-relative" href="#"
                 role="button" data-bs-toggle="dropdown"
                 id="notiDropdown" onclick="markAllRead()">
                <i class="fa fa-bell"></i>
                <span id="notiBadge"
                      class="position-absolute top-0 start-100 translate-middle
                             badge rounded-pill bg-danger"
                      style="font-size:10px;display:none;">0</span>
              </a>
              <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end"
                  style="width:320px;max-height:400px;overflow-y:auto;"
                  id="notiList">
                <li class="px-3 py-2 text-secondary small">불러오는 중...</li>
              </ul>
            </li>

            <!-- 컬렉션 드롭다운 -->
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#"
                 role="button" data-bs-toggle="dropdown">
                📁 컬렉션
              </a>
              <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end">
                <li><a class="dropdown-item" href="${ctp}/collection/list">내 컬렉션</a></li>
                <li><a class="dropdown-item" href="${ctp}/collection/public">공개 컬렉션 탐색</a></li>
              </ul>
            </li>

            <!-- 관리자 메뉴 -->
            <c:if test="${sessionScope.loginUser.userRole == 'ADMIN'}">
              <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#"
                   role="button" data-bs-toggle="dropdown">
                  ⚙ 관리자
                  <c:if test="${pendingReportCnt > 0}">
                    <span class="badge bg-danger ms-1" style="font-size:10px;">${pendingReportCnt}</span>
                  </c:if>
                </a>
                <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end">
                  <li><a class="dropdown-item" href="${ctp}/admin/dashboard">대시보드</a></li>
                  <li><a class="dropdown-item" href="${ctp}/admin/users">회원 관리</a></li>
                  <li><a class="dropdown-item" href="${ctp}/admin/reviews">리뷰 관리</a></li>
                  <li>
                    <a class="dropdown-item d-flex align-items-center justify-content-between"
                       href="${ctp}/admin/reports">
                      신고 관리
                      <c:if test="${pendingReportCnt > 0}">
                        <span class="badge bg-danger">${pendingReportCnt}</span>
                      </c:if>
                    </a>
                  </li>
                </ul>
              </li>
            </c:if>

            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/logout">로그아웃</a>
            </li>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>
  </div>
</nav>
<div style="margin-top:56px;"></div>

<c:if test="${not empty sessionScope.loginUser}">
<script>
var _ctp = '${ctp}';

/* ── 알림 수 폴링 (30초마다) ── */
function fetchNotiCount() {
    $.get(_ctp + '/notification/count', function(res) {
        var cnt = res.count || 0;
        if (cnt > 0) {
            $('#notiBadge').text(cnt > 99 ? '99+' : cnt).show();
        } else {
            $('#notiBadge').hide();
        }
    }, 'json');
}

/* ── 알림 목록 로드 (드롭다운 열릴 때) ── */
$('#notiDropdown').on('click', function() {
    $.get(_ctp + '/notification/list', function(list) {
        if (list.length === 0) {
            $('#notiList').html('<li class="px-3 py-2 text-secondary small">새 알림이 없습니다.</li>');
            return;
        }
        var html = '<li><h6 class="dropdown-header">알림</h6></li>';
        list.forEach(function(n) {
            var isRead = n.isRead == 1;
            html += '<li>';
            html += '<a class="dropdown-item py-2 ' + (isRead ? 'text-secondary' : 'fw-bold') + '"';
            html += ' href="' + _ctp + '/movie/detail/' + n.refId + '"';
            html += ' onclick="readNoti(' + n.notiId + ')">';
            html += '<div style="white-space:normal;font-size:13px;">';
            html += (isRead ? '' : '<span class="text-danger me-1">●</span>');
            html += n.message;
            html += '</div>';
            html += '<small class="text-secondary" style="font-size:11px;">' + (n.regDate || '') + '</small>';
            html += '</a></li>';
        });
        html += '<li><hr class="dropdown-divider"></li>';
        html += '<li><a class="dropdown-item text-center small text-secondary"';
        html += ' onclick="markAllRead()">전체 읽음 처리</a></li>';
        $('#notiList').html(html);
    }, 'json');
});

/* ── 단건 읽음 ── */
function readNoti(notiId) {
    $.post(_ctp + '/notification/read', { notiId: notiId });
}

/* ── 전체 읽음 ── */
function markAllRead() {
    $.post(_ctp + '/notification/readAll', function() {
        $('#notiBadge').hide();
    });
}

// 페이지 로드 시 + 30초마다 폴링
fetchNotiCount();
setInterval(fetchNotiCount, 30000);
</script>
</c:if>
