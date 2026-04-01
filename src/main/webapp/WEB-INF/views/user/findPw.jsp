<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>비밀번호 찾기 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>

  <style>
    :root{
      --watcha-point:#ff2f6e;
      --watcha-point-dark:#f22463;
      --watcha-point-soft:#fff1f5;
      --watcha-bg:#f7f7f8;
      --watcha-card:#ffffff;
      --watcha-text:#1f2937;
      --watcha-sub:#6b7280;
      --watcha-line:#e5e7eb;
      --watcha-input-bg:#f9fafb;
      --watcha-shadow:0 18px 40px rgba(0,0,0,0.08);
    }

    body{
      background:linear-gradient(180deg,#fbfbfc 0%, #f4f5f7 100%) !important;
      color:var(--watcha-text) !important;
      font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
    }

    a{
      text-decoration:none;
    }

    .find-wrap{
      min-height:calc(100vh - 160px);
      display:flex;
      align-items:center;
      justify-content:center;
      padding:56px 0;
    }

    .find-card{
      width:100%;
      max-width:560px;
      background:var(--watcha-card);
      border:1px solid #f0f0f0;
      border-radius:28px;
      box-shadow:var(--watcha-shadow);
      overflow:hidden;
    }

    .find-top{
      padding:34px 34px 18px 34px;
      text-align:center;
    }

    .find-badge{
      display:inline-block;
      padding:7px 14px;
      border-radius:999px;
      background:var(--watcha-point-soft);
      color:var(--watcha-point);
      font-size:13px;
      font-weight:700;
      margin-bottom:14px;
    }

    .find-title{
      font-size:1.9rem;
      font-weight:800;
      margin-bottom:8px;
      color:#111827;
    }

    .find-sub{
      font-size:14px;
      color:var(--watcha-sub);
      margin-bottom:0;
    }

    .find-body{
      padding:18px 34px 34px 34px;
    }

    .form-label{
      font-size:14px;
      font-weight:700;
      color:#374151;
      margin-bottom:8px;
    }

    .watcha-input{
      height:52px;
      border-radius:14px !important;
      border:1px solid var(--watcha-line) !important;
      background:var(--watcha-input-bg) !important;
      padding:0 16px;
      font-size:15px;
      color:#111827 !important;
      transition:all 0.2s ease;
      box-shadow:none !important;
    }

    .watcha-input::placeholder{
      color:#9ca3af !important;
    }

    .watcha-input:focus{
      background:#fff !important;
      border-color:#ff8fb2 !important;
      box-shadow:0 0 0 0.2rem rgba(255,47,110,0.12) !important;
      color:#111827 !important;
    }

    .input-group .btn{
      border-radius:14px !important;
      font-weight:700;
      min-width:110px;
    }

    .btn-outline-info,
    .btn-outline-warning,
    .btn-outline-secondary{
      background:#fff !important;
    }

    .btn-outline-info,
    .btn-outline-warning{
      color:var(--watcha-point) !important;
      border-color:#ffc2d4 !important;
    }

    .btn-outline-info:hover,
    .btn-outline-warning:hover{
      background:var(--watcha-point-soft) !important;
      border-color:#ff9fbc !important;
      color:var(--watcha-point-dark) !important;
    }

    .btn-outline-secondary{
      color:#6b7280 !important;
      border-color:#d1d5db !important;
    }

    .btn-outline-secondary:hover{
      background:#f9fafb !important;
      color:#374151 !important;
      border-color:#c4cbd4 !important;
    }

    .btn-main{
      height:52px;
      border:none;
      border-radius:14px;
      background:var(--watcha-point) !important;
      color:#fff !important;
      font-size:15px;
      font-weight:800;
      transition:all 0.2s ease;
    }

    .btn-main:hover{
      background:var(--watcha-point-dark) !important;
      color:#fff !important;
      transform:translateY(-1px);
    }

    .result-card{
      background:linear-gradient(135deg,#fff5f8 0%, #ffffff 100%);
      border:1px solid #ffe0ea;
      border-radius:22px;
      padding:28px 20px;
      text-align:center;
      margin-bottom:18px;
    }

    .result-title{
      font-size:1.2rem;
      font-weight:800;
      color:#111827;
      margin-bottom:8px;
    }

    .result-desc{
      color:var(--watcha-sub);
      font-size:14px;
      margin-bottom:0;
    }

    .fail-box{
      background:#fff;
      border:1px solid #ffd7df;
      border-radius:20px;
      padding:22px 18px;
      text-align:center;
      margin-bottom:16px;
    }

    .fail-box i{
      color:#ef4444;
    }

    .fail-text{
      color:#b91c1c;
      font-weight:700;
      margin-bottom:0;
    }

    .bottom-link{
      margin-top:18px;
      text-align:center;
      font-size:14px;
    }

    .bottom-link a{
      color:var(--watcha-sub) !important;
      font-weight:600;
      transition:color 0.2s ease;
    }

    .bottom-link a:hover{
      color:var(--watcha-point) !important;
    }

    #sendMsg, #codeMsg, #pwMsg, #pwCheckMsg{
      font-size:13px;
      padding-left:2px;
    }

    @media (max-width: 576px){
      .find-wrap{
        padding:24px 12px 40px 12px;
      }

      .find-card{
        border-radius:22px;
      }

      .find-top{
        padding:28px 22px 14px 22px;
      }

      .find-body{
        padding:14px 22px 28px 22px;
      }

      .find-title{
        font-size:1.6rem;
      }

      .input-group .btn{
        min-width:90px;
        font-size:14px;
      }
    }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container">
  <div class="find-wrap">
    <div class="find-card">
      <div class="find-top">
        <div class="find-badge">WATCHA PEDIA STYLE</div>
        <h3 class="find-title">비밀번호 찾기</h3>
        <p class="find-sub">아이디와 이메일 인증 후 새 비밀번호를 설정하세요</p>
      </div>

      <div class="find-body">

        <!-- Step 1 -->
        <div id="step1">
          <div class="mb-3">
            <label class="form-label">아이디</label>
            <input type="text"
                   class="form-control watcha-input"
                   id="userId"
                   placeholder="아이디 입력">
          </div>

          <div class="mb-3">
            <label class="form-label">이메일</label>
            <div class="input-group">
              <input type="email"
                     class="form-control watcha-input"
                     id="userEmail"
                     placeholder="가입한 이메일 입력">
              <button type="button"
                      class="btn btn-outline-info"
                      onclick="sendCode()">인증코드 발송</button>
            </div>
            <small id="sendMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">인증코드</label>
            <div class="input-group">
              <input type="text"
                     class="form-control watcha-input"
                     id="code"
                     placeholder="인증코드 입력">
              <button type="button"
                      class="btn btn-outline-warning"
                      onclick="checkCode()">확인</button>
            </div>
            <small id="codeMsg" class="mt-1 d-block"></small>
          </div>
        </div>

        <!-- Step 2 -->
        <div id="step2" style="display:none;">
          <div class="mb-3">
            <label class="form-label">새 비밀번호</label>
            <input type="password"
                   class="form-control watcha-input"
                   id="newPw"
                   placeholder="새 비밀번호 입력">
            <small id="pwMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">새 비밀번호 확인</label>
            <input type="password"
                   class="form-control watcha-input"
                   id="newPwCheck"
                   placeholder="새 비밀번호 다시 입력">
            <small id="pwCheckMsg" class="mt-1 d-block"></small>
          </div>

          <button type="button" class="btn btn-main w-100" onclick="changePw()">
            비밀번호 변경
          </button>
        </div>

        <!-- Step 3 -->
        <div id="step3" style="display:none;">
          <div class="result-card">
            <h4 class="result-title">비밀번호가 변경되었습니다</h4>
            <p class="result-desc">새 비밀번호로 다시 로그인해주세요.</p>
          </div>
          <a href="${ctp}/user/login" class="btn btn-main w-100">로그인</a>
        </div>

        <!-- 실패 -->
        <div id="stepFail" style="display:none;">
          <div class="fail-box">
            <i class="fa fa-exclamation-circle me-2"></i>
            <p class="fail-text d-inline">입력한 아이디와 이메일이 일치하지 않습니다.</p>
          </div>
          <a href="${ctp}/user/join" class="btn btn-outline-secondary w-100">
            회원가입하기
          </a>
        </div>

        <div class="bottom-link">
          <a href="${ctp}/user/login">로그인으로 돌아가기</a>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
var codeVerified = false;
var regPw = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,20}$/;

function sendCode() {
    var userId = $('#userId').val();
    var userEmail = $('#userEmail').val();

    if (!userId) { alert('아이디를 입력해주세요.'); return; }
    if (!userEmail) { alert('이메일을 입력해주세요.'); return; }

    $('#sendMsg').html('<span class="text-info">인증코드 발송 중...</span>');

    $.ajax({
        url: '${ctp}/user/findPw/sendCode',
        type: 'POST',
        data: {
            userId: userId,
            userEmail: userEmail
        },
        success: function(res) {
            if (res == 'ok') {
                $('#sendMsg').html('<span class="text-info">인증코드가 발송되었습니다. 5분 내 입력해주세요.</span>');
            } else if (res == 'notFound') {
                $('#sendMsg').html('');
                $('#step1').hide();
                $('#stepFail').show();
            } else {
                $('#sendMsg').html('<span class="text-danger">발송에 실패했습니다. 다시 시도해주세요.</span>');
            }
        }
    });
}

function checkCode() {
    var code = $('#code').val();
    if (!code) { alert('인증코드를 입력해주세요.'); return; }

    $.ajax({
        url: '${ctp}/user/checkEmailCode',
        type: 'POST',
        data: { code: code },
        success: function(res) {
            if (res == 'ok') {
                $('#codeMsg').html('<span class="text-success">인증이 완료되었습니다.</span>');
                $('#step1').hide();
                $('#step2').show();
                codeVerified = true;
            } else {
                $('#codeMsg').html('<span class="text-danger">인증코드가 올바르지 않습니다.</span>');
                codeVerified = false;
            }
        }
    });
}

$('#newPw').on('input', function() {
    if (!regPw.test($(this).val())) {
        $('#pwMsg').html('<span class="text-danger">영문+숫자+특수문자 8~20자로 입력해주세요.</span>');
    } else {
        $('#pwMsg').html('<span class="text-success">사용 가능한 비밀번호입니다.</span>');
    }
});

$('#newPwCheck').on('input', function() {
    if ($('#newPw').val() !== $(this).val()) {
        $('#pwCheckMsg').html('<span class="text-danger">비밀번호가 일치하지 않습니다.</span>');
    } else {
        $('#pwCheckMsg').html('<span class="text-success">비밀번호가 일치합니다.</span>');
    }
});

function changePw() {
    var userId = $('#userId').val();
    var newPw = $('#newPw').val();
    var newPwCheck = $('#newPwCheck').val();

    if (!codeVerified) {
        alert('이메일 인증을 먼저 완료해주세요.');
        return;
    }
    if (!regPw.test(newPw)) {
        alert('비밀번호 형식을 확인해주세요.');
        return;
    }
    if (newPw !== newPwCheck) {
        alert('비밀번호가 일치하지 않습니다.');
        return;
    }

    $.ajax({
        url: '${ctp}/user/findPw/changePw',
        type: 'POST',
        data: {
            userId: userId,
            newPw: newPw
        },
        success: function(res) {
            if (res == 'ok') {
                $('#step2').hide();
                $('#step3').show();
            } else {
                alert('비밀번호 변경에 실패했습니다.');
            }
        }
    });
}
</script>
</body>
</html>