<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>아이디 찾기 - SpringGreen8</title>
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
      max-width:520px;
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

    .btn-outline-info{
      color:var(--watcha-point) !important;
      border-color:#ffc2d4 !important;
      background:#fff !important;
    }

    .btn-outline-info:hover{
      background:var(--watcha-point-soft) !important;
      border-color:#ff9fbc !important;
      color:var(--watcha-point-dark) !important;
    }

    .btn-outline-warning{
      color:var(--watcha-point) !important;
      border-color:#ffc2d4 !important;
      background:#fff !important;
    }

    .btn-outline-warning:hover{
      background:var(--watcha-point-soft) !important;
      border-color:#ff9fbc !important;
      color:var(--watcha-point-dark) !important;
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

    .btn-sub{
      height:52px;
      border-radius:14px;
      font-weight:700;
    }

    .result-card{
      background:linear-gradient(135deg,#fff5f8 0%, #ffffff 100%);
      border:1px solid #ffe0ea;
      border-radius:22px;
      padding:28px 20px;
      text-align:center;
      margin-bottom:18px;
    }

    .result-label{
      color:var(--watcha-sub);
      font-size:14px;
      margin-bottom:10px;
    }

    .result-id{
      font-size:1.8rem;
      font-weight:900;
      color:var(--watcha-point);
      margin-bottom:6px;
      letter-spacing:0.5px;
    }

    .result-desc{
      color:var(--watcha-sub);
      font-size:13px;
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

    #emailMsg, #codeMsg{
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
        <h3 class="find-title">아이디 찾기</h3>
        <p class="find-sub">가입한 이메일 인증으로 아이디를 확인하세요</p>
      </div>

      <div class="find-body">

        <!-- Step 1: 이메일 입력 + 인증 -->
        <div id="step1">
          <div class="mb-3">
            <label class="form-label">가입시 등록한 이메일</label>
            <div class="input-group mb-2">
              <input type="email" class="form-control bg-secondary text-white border-0 watcha-input"
                     id="userEmail" placeholder="이메일 입력">
              <button type="button" class="btn btn-outline-info"
                      onclick="sendCode()">인증코드 발송</button>
            </div>
            <small id="emailMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">인증코드</label>
            <div class="input-group">
              <input type="text" class="form-control bg-secondary text-white border-0 watcha-input"
                     id="emailCode" placeholder="인증코드 6자리 입력">
              <button type="button" class="btn btn-outline-warning"
                      onclick="checkCode()">확인</button>
            </div>
            <small id="codeMsg" class="mt-1 d-block"></small>
          </div>
        </div>

        <!-- Step 2: 아이디 표시 (인증 후) -->
        <div id="step2" style="display:none;">
          <div class="result-card">
            <p class="result-label">회원님의 아이디는</p>
            <h3 class="result-id" id="foundId"></h3>
            <p class="result-desc">입니다.</p>
          </div>
          <div class="d-flex gap-2">
            <a href="${ctp}/user/login" class="btn btn-main w-100">로그인</a>
            <a href="${ctp}/user/findPw" class="btn btn-outline-secondary btn-sub w-100">비밀번호 찾기</a>
          </div>
        </div>

        <!-- Step 1 실패: 이메일 없는 경우 -->
        <div id="stepFail" style="display:none;">
          <div class="fail-box">
            <i class="fa fa-exclamation-circle me-2"></i>
            <p class="fail-text d-inline">해당 이메일로 가입된 계정이 없습니다.</p>
          </div>
          <a href="${ctp}/user/join" class="btn btn-outline-success w-100 btn-sub">
            회원가입하기
          </a>
        </div>

        <div class="bottom-link">
          <a href="${ctp}/user/login" class="text-secondary">로그인으로 돌아가기</a>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
/* ── 인증코드 발송 ── */
function sendCode() {
    var email = $('#userEmail').val();
    if (!email) { alert('이메일을 입력해주세요.'); return; }

    $('#emailMsg').html('<span class="text-info">인증코드 발송 중...</span>');
    $.ajax({
        url: '${ctp}/user/findId/sendCode',
        type: 'POST',
        data: { userEmail: email },
        success: function(res) {
            if (res == 'ok') {
                $('#emailMsg').html('<span class="text-info">인증코드가 발송되었습니다. 5분 내 입력해주세요.</span>');
            } else if (res == 'notFound') {
                $('#emailMsg').html('');
                $('#step1').hide();
                $('#stepFail').show();
            } else {
                $('#emailMsg').html('<span class="text-danger">발송에 실패했습니다. 다시 시도해주세요.</span>');
            }
        }
    });
}

/* ── 인증코드 확인 ── */
function checkCode() {
    var code = $('#emailCode').val();
    if (!code) { alert('인증코드를 입력해주세요.'); return; }

    $.ajax({
        url: '${ctp}/user/findId/checkCode',
        type: 'POST',
        data: { code: code },
        success: function(res) {
            if (res != 'fail') {
                // res 에 아이디가 담겨옴
                $('#codeMsg').html('<span class="text-success">인증이 완료되었습니다.</span>');
                $('#step1').hide();
                $('#foundId').text(res);
                $('#step2').show();
            } else {
                $('#codeMsg').html('<span class="text-danger">인증코드가 올바르지 않습니다.</span>');
            }
        }
    });
}
</script>
</body>
</html>