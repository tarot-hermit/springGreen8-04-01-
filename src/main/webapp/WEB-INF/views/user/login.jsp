<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>로그인 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    :root{
      --point:#ff2f6e; --point-dark:#f22463;
      --point-soft:#fff1f5; --bg:#f7f7f8;
      --card:#ffffff; --text:#1f2937;
      --sub:#6b7280; --line:#e5e7eb;
      --shadow:0 18px 40px rgba(0,0,0,0.08);
    }
    body{ background:linear-gradient(180deg,#fbfbfc 0%,#f4f5f7 100%);
          color:var(--text);
          font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif; }
    a{ text-decoration:none; }
    .login-wrap{ min-height:calc(100vh - 160px); display:flex;
                 align-items:center; justify-content:center; padding:56px 0; }
    .login-card{ width:100%; max-width:440px; background:var(--card);
                 border:1px solid #f0f0f0; border-radius:28px;
                 box-shadow:var(--shadow); overflow:hidden; }
    .login-top{ padding:34px 34px 18px 34px; text-align:center; }
    .login-badge{ display:inline-block; padding:7px 14px; border-radius:999px;
                  background:var(--point-soft); color:var(--point);
                  font-size:13px; font-weight:700; margin-bottom:14px; }
    .login-title{ font-size:1.9rem; font-weight:800; margin-bottom:8px; color:#111827; }
    .login-sub{ font-size:14px; color:var(--sub); margin-bottom:0; }
    .login-body{ padding:18px 34px 34px 34px; }
    .form-label{ font-size:14px; font-weight:700; color:#374151; margin-bottom:8px; }
    .watcha-input{ height:52px; border-radius:14px; border:1px solid var(--line);
                   background:#f9fafb; padding:0 16px; font-size:15px; color:#111827;
                   transition:all 0.2s ease; box-shadow:none; }
    .watcha-input::placeholder{ color:#9ca3af; }
    .watcha-input:focus{ background:#fff; border-color:#ff8fb2;
                         box-shadow:0 0 0 0.2rem rgba(255,47,110,0.12); color:#111827; }
    .login-btn{ height:54px; border:none; border-radius:14px; background:var(--point);
                color:#fff; font-size:16px; font-weight:800; transition:all 0.2s ease; }
    .login-btn:hover{ background:var(--point-dark); color:#fff; transform:translateY(-1px); }
    .link-area{ margin-top:22px; text-align:center; line-height:1.9; }
    .link-area a{ color:#6b7280; font-size:14px; font-weight:600; transition:color 0.2s ease; }
    .link-area a:hover{ color:var(--point); }
    .divider{ color:#d1d5db; margin:0 8px; }
    @media (max-width:576px){
      .login-wrap{ padding:24px 12px 40px 12px; }
      .login-card{ border-radius:22px; }
      .login-top{ padding:28px 22px 14px 22px; }
      .login-body{ padding:14px 22px 28px 22px; }
      .login-title{ font-size:1.6rem; }
    }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container">
  <div class="login-wrap">
    <div class="login-card">
      <div class="login-top">
        <div class="login-badge">WATCHA PEDIA STYLE</div>
        <h3 class="login-title">로그인</h3>
        <p class="login-sub">취향에 맞는 영화와 리뷰를 만나보세요</p>
      </div>

      <div class="login-body">
        <form id="loginForm" action="${ctp}/user/login" method="post">
          <div class="mb-3">
            <label class="form-label">아이디</label>
            <input type="text" class="form-control watcha-input"
                   name="userId" id="userId" placeholder="아이디 입력" required>
          </div>
          <div class="mb-4">
            <label class="form-label">비밀번호</label>
            <input type="password" class="form-control watcha-input"
                   name="userPw" id="userPw" placeholder="비밀번호 입력" required>
          </div>
          <button type="submit" class="btn login-btn w-100">로그인</button>
          <div class="link-area">
            <a href="${ctp}/user/join">계정이 없으신가요? 회원가입</a><br/>
            <a href="${ctp}/user/findId">아이디 찾기</a>
            <span class="divider">|</span>
            <a href="${ctp}/user/findPw">비밀번호 찾기</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
$('#loginForm').on('submit', function(e) {
    var userId = $('#userId').val().trim();
    var userPw = $('#userPw').val().trim();

    if (!userId) {
        e.preventDefault();
        Swal.fire({ icon: 'warning', title: '아이디 필요', text: '아이디를 입력해주세요.' })
            .then(() => $('#userId').focus());
        return;
    }
    if (!userPw) {
        e.preventDefault();
        Swal.fire({ icon: 'warning', title: '비밀번호 필요', text: '비밀번호를 입력해주세요.' })
            .then(() => $('#userPw').focus());
        return;
    }
});
</script>
</body>
</html>
