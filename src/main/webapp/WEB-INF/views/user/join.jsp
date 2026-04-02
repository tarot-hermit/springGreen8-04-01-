<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>회원가입 - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <style>
    :root{
      --watcha-point:#ff2f6e; --watcha-point-dark:#f22463;
      --watcha-point-soft:#fff1f5; --watcha-bg:#f7f7f8;
      --watcha-card:#ffffff; --watcha-text:#1f2937;
      --watcha-sub:#6b7280; --watcha-line:#e5e7eb;
      --watcha-input-bg:#f9fafb; --watcha-shadow:0 18px 40px rgba(0,0,0,0.08);
    }
    body{ background:linear-gradient(180deg,#fbfbfc 0%,#f4f5f7 100%) !important;
          color:var(--watcha-text) !important;
          font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif; }
    a{ text-decoration:none; }
    .join-wrap{ min-height:calc(100vh - 160px); display:flex; align-items:center;
                justify-content:center; padding:56px 0; }
    .join-card{ width:100%; max-width:560px; background:var(--watcha-card);
                border:1px solid #f0f0f0; border-radius:28px;
                box-shadow:var(--watcha-shadow); overflow:hidden; }
    .join-top{ padding:34px 34px 18px 34px; text-align:center; }
    .join-badge{ display:inline-block; padding:7px 14px; border-radius:999px;
                 background:var(--watcha-point-soft); color:var(--watcha-point);
                 font-size:13px; font-weight:700; margin-bottom:14px; }
    .join-title{ font-size:1.9rem; font-weight:800; margin-bottom:8px; color:#111827; }
    .join-sub{ font-size:14px; color:var(--watcha-sub); margin-bottom:0; }
    .join-body{ padding:18px 34px 34px 34px; }
    .form-label{ font-size:14px; font-weight:700; color:#374151; margin-bottom:8px; }
    .watcha-input{ height:52px; border-radius:14px !important;
                   border:1px solid var(--watcha-line) !important;
                   background:var(--watcha-input-bg) !important;
                   padding:0 16px; font-size:15px; color:#111827 !important;
                   transition:all 0.2s ease; box-shadow:none !important; }
    .watcha-input::placeholder{ color:#9ca3af !important; }
    .watcha-input:focus{ background:#fff !important; border-color:#ff8fb2 !important;
                         box-shadow:0 0 0 0.2rem rgba(255,47,110,0.12) !important;
                         color:#111827 !important; }
    .input-group .btn{ border-radius:14px !important; font-weight:700; min-width:110px; }
    .btn-outline-success{ color:var(--watcha-point) !important; border-color:#ffc2d4 !important; background:#fff !important; }
    .btn-outline-success:hover{ background:var(--watcha-point-soft) !important; border-color:#ff9fbc !important; color:var(--watcha-point-dark) !important; }
    .btn-outline-info{ color:var(--watcha-point) !important; border-color:#ffc2d4 !important; background:#fff !important; }
    .btn-outline-info:hover{ background:var(--watcha-point-soft) !important; border-color:#ff9fbc !important; color:var(--watcha-point-dark) !important; }
    .btn-outline-warning{ color:var(--watcha-point) !important; border-color:#ffc2d4 !important; background:#fff !important; }
    .btn-outline-warning:hover{ background:var(--watcha-point-soft) !important; border-color:#ff9fbc !important; color:var(--watcha-point-dark) !important; }
    .btn-outline-secondary{ color:#6b7280 !important; border-color:#d1d5db !important; background:#fff !important; }
    .btn-outline-secondary:hover{ background:#f9fafb !important; color:#374151 !important; border-color:#c4cbd4 !important; }
    .join-btn{ height:54px; border:none; border-radius:14px;
               background:var(--watcha-point) !important; color:#fff !important;
               font-size:16px; font-weight:800; transition:all 0.2s ease; }
    .join-btn:hover{ background:var(--watcha-point-dark) !important; color:#fff !important; transform:translateY(-1px); }
    .login-link{ margin-top:18px; text-align:center; font-size:14px; }
    .login-link a{ color:var(--watcha-sub) !important; font-weight:600; transition:color 0.2s ease; }
    .login-link a:hover{ color:var(--watcha-point) !important; }
    #idMsg,#pwMsg,#pwCheckMsg,#nameMsg,#emailMsg{ font-size:13px; padding-left:2px; }
    @media (max-width:576px){
      .join-wrap{ padding:24px 12px 40px 12px; }
      .join-card{ border-radius:22px; }
      .join-top{ padding:28px 22px 14px 22px; }
      .join-body{ padding:14px 22px 28px 22px; }
      .join-title{ font-size:1.6rem; }
      .input-group .btn{ min-width:90px; font-size:14px; }
    }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container">
  <div class="join-wrap">
    <div class="join-card">
      <div class="join-top">
        <div class="join-badge">WATCHA PEDIA STYLE</div>
        <h3 class="join-title">회원가입</h3>
        <p class="join-sub">취향 기반 영화 서비스를 시작해보세요</p>
      </div>

      <div class="join-body">
        <%-- onsubmit 제거 — JS에서 preventDefault로 처리 --%>
        <form id="joinForm" action="${ctp}/user/join" method="post">

          <div class="mb-3">
            <label class="form-label">아이디 <span class="text-danger">*</span></label>
            <div class="input-group">
              <input type="text" class="form-control bg-secondary text-white border-0 watcha-input"
                     name="userId" id="userId" placeholder="영문+숫자 4~15자" required>
              <button type="button" class="btn btn-outline-success" onclick="checkId()">중복확인</button>
            </div>
            <small id="idMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">비밀번호 <span class="text-danger">*</span></label>
            <input type="password" class="form-control bg-secondary text-white border-0 watcha-input"
                   name="userPw" id="userPw" placeholder="영문+숫자+특수문자 8~20자" required>
            <small id="pwMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">비밀번호 확인 <span class="text-danger">*</span></label>
            <input type="password" class="form-control bg-secondary text-white border-0 watcha-input"
                   id="userPwCheck" placeholder="비밀번호 재입력" required>
            <small id="pwCheckMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">닉네임 <span class="text-danger">*</span></label>
            <input type="text" class="form-control bg-secondary text-white border-0 watcha-input"
                   name="userName" id="userName" placeholder="한글/영문 2~10자" required>
            <small id="nameMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">이메일 <span class="text-danger">*</span></label>
            <div class="input-group mb-2">
              <input type="email" class="form-control bg-secondary text-white border-0 watcha-input"
                     name="userEmail" id="userEmail" placeholder="이메일 입력" required>
              <button type="button" class="btn btn-outline-info" onclick="sendEmail()">인증코드 발송</button>
            </div>
            <div class="input-group">
              <input type="text" class="form-control bg-secondary text-white border-0 watcha-input"
                     id="emailCode" placeholder="인증코드 6자리 입력">
              <button type="button" class="btn btn-outline-warning" onclick="checkEmailCode()">확인</button>
            </div>
            <small id="emailMsg" class="mt-1 d-block"></small>
          </div>

          <div class="mb-3">
            <label class="form-label">주소</label>
            <div class="input-group mb-2">
              <input type="text" class="form-control bg-secondary text-white border-0 watcha-input"
                     name="userZipcode" id="userZipcode" placeholder="우편번호" readonly>
              <button type="button" class="btn btn-outline-secondary" onclick="searchAddr()">주소 검색</button>
            </div>
            <input type="text" class="form-control bg-secondary text-white border-0 mb-2 watcha-input"
                   name="userAddr1" id="userAddr1" placeholder="기본주소" readonly>
            <input type="text" class="form-control bg-secondary text-white border-0 watcha-input"
                   name="userAddr2" id="userAddr2" placeholder="상세주소 입력">
          </div>

          <button type="submit" class="btn btn-success w-100 mt-2 join-btn">가입하기</button>
          <div class="login-link text-center mt-3">
            <a href="${ctp}/user/login" class="text-secondary">이미 계정이 있으신가요? 로그인</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
var idChecked     = false;
var emailVerified = false;
var ctp = '${ctp}';

var regId   = /^[a-zA-Z0-9]{4,15}$/;
var regPw   = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,20}$/;
var regName = /^[가-힣a-zA-Z]{2,10}$/;

/* ── Toast 헬퍼 ── */
var Toast = Swal.mixin({
    toast: true, position: 'top-end',
    showConfirmButton: false, timer: 2000,
    timerProgressBar: true
});

/* ── 아이디 중복확인 ── */
function checkId() {
    var userId = $('#userId').val();
    if (!regId.test(userId)) {
        $('#idMsg').html('<span class="text-danger">영문+숫자 4~15자로 입력해주세요.</span>');
        idChecked = false; return;
    }
    $.ajax({
        url: ctp + '/user/checkId', type: 'POST', data: { userId: userId },
        success: function(res) {
            if (res == 'dup') {
                $('#idMsg').html('<span class="text-danger">이미 사용중인 아이디입니다.</span>');
                idChecked = false;
            } else {
                $('#idMsg').html('<span class="text-success">사용 가능한 아이디입니다.</span>');
                idChecked = true;
                Toast.fire({ icon: 'success', title: '사용 가능한 아이디입니다.' });
            }
        }
    });
}

/* ── 비밀번호 실시간 체크 ── */
$('#userPw').on('input', function() {
    if (!regPw.test($(this).val())) {
        $('#pwMsg').html('<span class="text-danger">영문+숫자+특수문자(!@#$%^&*) 8~20자로 입력해주세요.</span>');
    } else {
        $('#pwMsg').html('<span class="text-success">✓ 사용 가능한 비밀번호입니다.</span>');
    }
});

$('#userPwCheck').on('input', function() {
    if ($('#userPw').val() !== $(this).val()) {
        $('#pwCheckMsg').html('<span class="text-danger">비밀번호가 일치하지 않습니다.</span>');
    } else {
        $('#pwCheckMsg').html('<span class="text-success">✓ 비밀번호가 일치합니다.</span>');
    }
});

/* ── 닉네임 실시간 체크 ── */
$('#userName').on('input', function() {
    if (!regName.test($(this).val())) {
        $('#nameMsg').html('<span class="text-danger">한글/영문 2~10자로 입력해주세요.</span>');
    } else {
        $('#nameMsg').html('<span class="text-success">✓ 사용 가능한 닉네임입니다.</span>');
    }
});

/* ── 이메일 인증코드 발송 ── */
function sendEmail() {
    var email = $('#userEmail').val();
    if (!email) {
        Swal.fire({ icon: 'warning', title: '이메일 필요', text: '이메일을 입력해주세요.' });
        return;
    }
    $.ajax({
        url: ctp + '/user/checkEmail', type: 'POST', data: { userEmail: email },
        success: function(res) {
            if (res == 'dup') {
                $('#emailMsg').html('<span class="text-danger">이미 사용중인 이메일입니다.</span>');
                return;
            }
            // 로딩 스피너
            Swal.fire({
                title: '인증코드 발송 중...',
                text: '잠시만 기다려주세요.',
                allowOutsideClick: false,
                didOpen: function() { Swal.showLoading(); }
            });
            $.ajax({
                url: ctp + '/user/sendEmail', type: 'POST', data: { userEmail: email },
                success: function(res2) {
                    Swal.close();
                    if (res2 == 'ok') {
                        $('#emailMsg').html('<span class="text-info">✓ 인증코드가 발송되었습니다. 5분 내 입력해주세요.</span>');
                        Toast.fire({ icon: 'success', title: '인증코드가 발송되었습니다.' });
                    } else {
                        Swal.fire({ icon: 'error', title: '발송 실패', text: '이메일 주소를 확인해주세요.' });
                    }
                },
                error: function() {
                    Swal.close();
                    Swal.fire({ icon: 'error', title: '발송 실패', text: '잠시 후 다시 시도해주세요.' });
                }
            });
        }
    });
}

/* ── 이메일 인증코드 확인 ── */
function checkEmailCode() {
    var code = $('#emailCode').val();
    if (!code) {
        Swal.fire({ icon: 'warning', title: '코드 필요', text: '인증코드를 입력해주세요.' });
        return;
    }
    $.ajax({
        url: ctp + '/user/checkEmailCode', type: 'POST', data: { code: code },
        success: function(res) {
            if (res == 'ok') {
                $('#emailMsg').html('<span class="text-success">✓ 이메일 인증이 완료되었습니다.</span>');
                emailVerified = true;
                Toast.fire({ icon: 'success', title: '이메일 인증 완료!' });
            } else {
                $('#emailMsg').html('<span class="text-danger">인증코드가 올바르지 않습니다.</span>');
                emailVerified = false;
                Swal.fire({ icon: 'error', title: '인증 실패', text: '인증코드가 올바르지 않습니다.' });
            }
        }
    });
}

/* ── 카카오 주소 검색 ── */
function searchAddr() {
    new daum.Postcode({
        oncomplete: function(data) {
            $('#userZipcode').val(data.zonecode);
            $('#userAddr1').val(data.roadAddress || data.jibunAddress);
            $('#userAddr2').focus();
            Toast.fire({ icon: 'success', title: '주소가 입력되었습니다.' });
        }
    }).open();
}

/* ── 폼 제출 — Swal confirm 후 submit ── */
$('#joinForm').on('submit', function(e) {
    e.preventDefault();
    var form = this;

    if (!idChecked) {
        Swal.fire({ icon: 'warning', title: '중복확인 필요', text: '아이디 중복확인을 해주세요.' });
        return;
    }
    if (!regPw.test($('#userPw').val())) {
        Swal.fire({ icon: 'warning', title: '비밀번호 오류', text: '비밀번호 형식을 확인해주세요.' });
        return;
    }
    if ($('#userPw').val() !== $('#userPwCheck').val()) {
        Swal.fire({ icon: 'warning', title: '비밀번호 불일치', text: '비밀번호가 일치하지 않습니다.' });
        return;
    }
    if (!regName.test($('#userName').val())) {
        Swal.fire({ icon: 'warning', title: '닉네임 오류', text: '닉네임 형식을 확인해주세요.' });
        return;
    }
    if (!emailVerified) {
        Swal.fire({ icon: 'warning', title: '이메일 인증 필요', text: '이메일 인증을 완료해주세요.' });
        return;
    }

    Swal.fire({
        icon: 'question',
        title: '회원가입',
        text: '입력하신 정보로 가입하시겠습니까?',
        showCancelButton: true,
        confirmButtonText: '가입하기',
        cancelButtonText: '취소',
        confirmButtonColor: '#ff2f6e'
    }).then(function(result) {
        if (result.isConfirmed) form.submit();
    });
});
</script>
</body>
</html>
