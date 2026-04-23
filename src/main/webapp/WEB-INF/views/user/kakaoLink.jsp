<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>카카오 계정 연결 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    :root{
      --point:#ff2f6e; --point-dark:#f22463;
      --point-soft:#fff1f5; --card:#ffffff; --text:#1f2937;
      --sub:#6b7280; --line:#e5e7eb; --shadow:0 18px 40px rgba(0,0,0,0.08);
    }
    body{ background:linear-gradient(180deg,#fbfbfc 0%,#f4f5f7 100%);
          color:var(--text);
          font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif; }
    a{ text-decoration:none; }
    .link-wrap{ min-height:calc(100vh - 160px); display:flex;
                align-items:center; justify-content:center; padding:56px 0; }
    .link-card{ width:100%; max-width:480px; background:var(--card);
                border:1px solid #f0f0f0; border-radius:24px;
                box-shadow:var(--shadow); overflow:hidden; }
    .link-top{ padding:34px 34px 16px 34px; text-align:center; }
    .link-badge{ display:inline-block; padding:7px 14px; border-radius:999px;
                 background:#fff7c2; color:#3b2f00;
                 font-size:13px; font-weight:800; margin-bottom:14px; }
    .link-title{ font-size:1.8rem; font-weight:800; margin-bottom:8px; color:#111827; }
    .link-sub{ font-size:14px; color:var(--sub); margin-bottom:0; line-height:1.6; }
    .link-body{ padding:18px 34px 34px 34px; }
    .profile-box{ border:1px solid var(--line); border-radius:8px; padding:14px 16px;
                  background:#f9fafb; color:#374151; font-size:14px; margin-bottom:18px; }
    .form-label{ font-size:14px; font-weight:700; color:#374151; margin-bottom:8px; }
    .link-input{ height:52px; border-radius:8px; border:1px solid var(--line);
                 background:#f9fafb; padding:0 16px; font-size:15px; color:#111827;
                 transition:all 0.2s ease; box-shadow:none; }
    .link-input:focus{ background:#fff; border-color:#ff8fb2;
                       box-shadow:0 0 0 0.2rem rgba(255,47,110,0.12); color:#111827; }
    .primary-btn{ height:54px; border:none; border-radius:8px; background:var(--point);
                  color:#fff; font-size:16px; font-weight:800; transition:all 0.2s ease; }
    .primary-btn:hover{ background:var(--point-dark); color:#fff; transform:translateY(-1px); }
    .kakao-join-btn{ height:52px; border:1px solid #f7e600; border-radius:8px; background:#fee500;
                     color:#191919; font-size:15px; font-weight:800;
                     display:flex; align-items:center; justify-content:center; width:100%; }
    .kakao-join-btn:hover{ background:#f7dc00; color:#191919; }
    .divider-text{ text-align:center; color:#9ca3af; font-size:13px; margin:18px 0 12px; }
    @media (max-width:576px){
      .link-wrap{ padding:24px 12px 40px 12px; }
      .link-card{ border-radius:18px; }
      .link-top{ padding:28px 22px 14px 22px; }
      .link-body{ padding:14px 22px 28px 22px; }
      .link-title{ font-size:1.55rem; }
    }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container">
  <div class="link-wrap">
    <div class="link-card">
      <div class="link-top">
        <div class="link-badge">KAKAO</div>
        <h3 class="link-title">계정 연결</h3>
        <p class="link-sub">이미 쓰던 계정이 있다면 카카오 로그인을 그 계정에 연결하세요.</p>
      </div>

      <div class="link-body">
        <div class="profile-box">
          <div><strong>카카오 닉네임</strong> ${kakaoProfile.nickname}</div>
          <c:if test="${not empty kakaoProfile.email}">
            <div><strong>카카오 이메일</strong> ${kakaoProfile.email}</div>
          </c:if>
        </div>

        <form action="${ctp}/user/kakao/link" method="post">
          <div class="mb-3">
            <label class="form-label">기존 아이디</label>
            <input type="text" class="form-control link-input" name="userId" required>
          </div>
          <div class="mb-4">
            <label class="form-label">기존 비밀번호</label>
            <input type="password" class="form-control link-input" name="userPw" required>
          </div>
          <button type="submit" class="btn primary-btn w-100">기존 계정에 연결</button>
        </form>

        <div class="divider-text">기존 계정이 없다면</div>
        <form action="${ctp}/user/kakao/join" method="post">
          <button type="submit" class="kakao-join-btn">카카오 계정으로 새로 시작</button>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
