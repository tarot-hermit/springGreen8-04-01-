<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
  <div class="container-fluid">
    <!-- 로고 -->
    <a class="navbar-brand fw-bold text-success" href="${ctp}/">
      <i class="fa fa-film"></i> SpringGreen8
    </a>
    <!-- 토글 버튼 (모바일) -->
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
	  <!-- 장르 드롭다운 추가 -->
	  <li class="nav-item dropdown">
	    <a class="nav-link dropdown-toggle" href="#"
	       data-bs-toggle="dropdown">장르</a>
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
	</ul>

      <!-- 검색창 (가운데) -->
      <form class="d-flex mx-auto" style="width:350px;"
            action="${ctp}/movie/search" method="get">
        <div class="input-group">
          <input type="text" class="form-control bg-secondary text-white border-0"
                 name="q" id="navSearch"
                 placeholder="영화 검색..."
                 autocomplete="off"
                 value="${param.q}">
          <button type="submit" class="btn btn-success">
            <i class="fa fa-search"></i>
          </button>
        </div>
      </form>

      <!-- 오른쪽 메뉴 -->
      <ul class="navbar-nav ms-auto">
        <c:choose>
          <c:when test="${empty sessionScope.loginUser}">
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/login">로그인</a>
            </li>
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/join">회원가입</a>
            </li>
          </c:when>
          <c:otherwise>
            <li class="nav-item">
              <a class="nav-link" href="${ctp}/user/mypage">
                <i class="fa fa-user"></i> ${sessionScope.loginUser.userName}
              </a>
            </li>
            <c:if test="${sessionScope.loginUser.userRole == 'ADMIN'}">
			  <li class="nav-item">
			    <a class="nav-link text-success fw-bold" href="${ctp}/admin/dashboard">
			      <i class="fa fa-cog"></i> 관리자
			    </a>
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