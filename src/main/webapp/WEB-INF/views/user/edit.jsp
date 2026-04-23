<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>프로필 수정 - SpringGreen8</title>
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

    .edit-wrap{
      min-height:calc(100vh - 160px);
      display:flex;
      align-items:center;
      justify-content:center;
      padding:56px 0;
    }

    .edit-card{
      width:100%;
      max-width:620px;
      background:var(--watcha-card);
      border:1px solid #f0f0f0;
      border-radius:28px;
      box-shadow:var(--watcha-shadow);
      overflow:hidden;
    }

    .edit-top{
      padding:34px 34px 18px 34px;
      text-align:center;
      background:linear-gradient(135deg, #fff5f8 0%, #ffffff 55%, #fff8fb 100%);
    }

    .edit-badge{
      display:inline-block;
      padding:7px 14px;
      border-radius:999px;
      background:var(--watcha-point-soft);
      color:var(--watcha-point);
      font-size:13px;
      font-weight:700;
      margin-bottom:14px;
    }

    .edit-title{
      font-size:1.9rem;
      font-weight:800;
      margin-bottom:8px;
      color:#111827;
    }

    .edit-sub{
      font-size:14px;
      color:var(--watcha-sub);
      margin-bottom:0;
    }

    .edit-body{
      padding:18px 34px 34px 34px;
    }

    .form-label{
      font-size:14px;
      font-weight:700;
      color:#374151;
      margin-bottom:8px;
    }

    .watcha-input{
      min-height:52px;
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

    textarea.watcha-input{
      min-height:120px;
      padding:14px 16px;
      resize:none;
    }

    .profile-box{
      text-align:center;
      margin-bottom:28px;
    }

    .profile-preview{
      width:110px;
      height:110px;
      object-fit:cover;
      border-radius:50%;
      border:4px solid #fff;
      box-shadow:0 10px 24px rgba(0,0,0,0.10);
      background:#f3f4f6;
      display:block;
      margin:0 auto 14px auto;
    }

    .file-guide{
      font-size:12px;
      color:var(--watcha-sub);
      margin-top:6px;
      margin-bottom:0;
    }

    .setting-section{
      margin-top:32px;
      padding-top:28px;
      border-top:1px solid var(--watcha-line);
    }

    .section-title{
      font-size:1.05rem;
      font-weight:800;
      color:#111827;
      margin-bottom:6px;
    }

    .section-desc{
      font-size:13px;
      color:var(--watcha-sub);
      margin-bottom:18px;
    }

    .input-guide{
      min-height:18px;
      font-size:12px;
      margin-top:6px;
      color:var(--watcha-sub);
    }

    .edit-btn{
      height:54px;
      border:none;
      border-radius:14px;
      background:var(--watcha-point) !important;
      color:#fff !important;
      font-size:16px;
      font-weight:800;
      transition:all 0.2s ease;
    }

    .edit-btn:hover{
      background:var(--watcha-point-dark) !important;
      color:#fff !important;
      transform:translateY(-1px);
    }

    .back-link{
      margin-top:18px;
      text-align:center;
      font-size:14px;
    }

    .back-link a{
      color:var(--watcha-sub) !important;
      font-weight:600;
      transition:color 0.2s ease;
    }

    .back-link a:hover{
      color:var(--watcha-point) !important;
    }

    @media (max-width: 576px){
      .edit-wrap{
        padding:24px 12px 40px 12px;
      }

      .edit-card{
        border-radius:22px;
      }

      .edit-top{
        padding:28px 22px 14px 22px;
      }

      .edit-body{
        padding:14px 22px 28px 22px;
      }

      .edit-title{
        font-size:1.6rem;
      }
    }
  </style>

  <script>
    'use strict';

    const PASSWORD_REGEX = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,20}$/;
    const NICKNAME_REGEX = /^[가-힣a-zA-Z0-9]{2,10}$/;
    const EMAIL_REGEX = /^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/;

    function previewImage(input) {
      const file = input.files[0];
      const preview = document.getElementById('profilePreview');

      if (!file) return;

      const maxSize = 10 * 1024 * 1024;
      if (file.size > maxSize) {
        alert('이미지는 10MB 이하만 업로드 가능합니다.');
        input.value = '';
        return;
      }

      const ext = file.name.substring(file.name.lastIndexOf('.') + 1).toLowerCase();
      if (ext !== 'jpg' && ext !== 'jpeg' && ext !== 'png' && ext !== 'gif') {
        alert('jpg, jpeg, png, gif 파일만 업로드 가능합니다.');
        input.value = '';
        return;
      }

      const reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }

    $(function() {
      $('#profileForm').on('submit', function(e) {
        var userName = $('input[name="userName"]').val().trim();
        var userEmail = $('input[name="userEmail"]').val().trim();
        var userBio = $('textarea[name="userBio"]').val().trim();

        if (!NICKNAME_REGEX.test(userName)) {
          alert('닉네임은 한글, 영문, 숫자 2~10자로 입력해주세요.');
          e.preventDefault();
          return;
        }

        if (!EMAIL_REGEX.test(userEmail)) {
          alert('올바른 이메일 형식으로 입력해주세요.');
          e.preventDefault();
          return;
        }

        if (userBio.length > 300) {
          alert('자기소개는 300자 이하로 입력해주세요.');
          e.preventDefault();
        }
      });

      $('#newPw').on('input', function() {
        if (!PASSWORD_REGEX.test($(this).val())) {
          $('#pwGuide').html('<span class="text-danger">영문+숫자+특수문자(!@#$%^&*) 8~20자로 입력해주세요.</span>');
        } else {
          $('#pwGuide').html('<span class="text-success">사용 가능한 비밀번호 형식입니다.</span>');
        }
      });

      $('#newPwCheck').on('input', function() {
        if ($('#newPw').val() !== $(this).val()) {
          $('#pwMatchGuide').html('<span class="text-danger">비밀번호가 일치하지 않습니다.</span>');
        } else {
          $('#pwMatchGuide').html('<span class="text-success">비밀번호가 일치합니다.</span>');
        }
      });

      $('#passwordForm').on('submit', function(e) {
        var currentPw = $('#currentPw').val();
        var newPw = $('#newPw').val();
        var newPwCheck = $('#newPwCheck').val();

        if (!currentPw || !newPw || !newPwCheck) {
          alert('현재 비밀번호와 새 비밀번호를 모두 입력해주세요.');
          e.preventDefault();
          return;
        }

        if (!PASSWORD_REGEX.test(newPw)) {
          alert('새 비밀번호는 영문, 숫자, 특수문자(!@#$%^&*)를 포함한 8~20자로 입력해주세요.');
          e.preventDefault();
          return;
        }

        if (newPw !== newPwCheck) {
          alert('새 비밀번호 확인이 일치하지 않습니다.');
          e.preventDefault();
          return;
        }

        if (currentPw === newPw) {
          alert('새 비밀번호는 현재 비밀번호와 다르게 설정해주세요.');
          e.preventDefault();
        }
      });
    });
  </script>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container">
  <div class="edit-wrap">
    <div class="edit-card">
      <div class="edit-top">
        <div class="edit-badge">WATCHA PEDIA STYLE</div>
        <h3 class="edit-title">프로필 수정</h3>
        <p class="edit-sub">내 정보와 프로필 이미지를 수정해보세요</p>
      </div>

      <div class="edit-body">
        <!-- 중요: multipart/form-data -->
        <form id="profileForm" action="${ctp}/user/edit" method="post" enctype="multipart/form-data">

          <!-- 중요: 파일 input name = imgFile -->
          <div class="profile-box">
            <img src="${ctp}/data/${user.userImg}"
                 id="profilePreview"
                 class="profile-preview"
                 onerror="this.src='https://placehold.co/110x110?text=User'">

            <label class="form-label d-block">프로필 이미지</label>
            <input type="file"
                   name="imgFile"
                   class="form-control watcha-input"
                   accept=".jpg,.jpeg,.png,.gif"
                   onchange="previewImage(this)">
            <p class="file-guide">10MB 이하 이미지 파일만 업로드 가능합니다.</p>
          </div>

          <div class="mb-3">
            <label class="form-label">닉네임</label>
            <input type="text"
                    name="userName"
                    value="${fn:escapeXml(user.userName)}"
                    class="form-control watcha-input"
                    placeholder="한글/영문/숫자 2~10자"
                    maxlength="10">
          </div>

          <div class="mb-3">
            <label class="form-label">이메일</label>
            <input type="email"
                    name="userEmail"
                    value="${fn:escapeXml(user.userEmail)}"
                    class="form-control watcha-input"
                    placeholder="이메일 입력"
                    maxlength="100">
          </div>

          <div class="mb-3">
            <label class="form-label">자기소개</label>
            <textarea name="userBio"
                      class="form-control watcha-input"
                      placeholder="간단한 자기소개를 입력해보세요"
                      maxlength="300">${fn:escapeXml(user.userBio)}</textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">우편번호</label>
            <input type="text"
                   name="userZipcode"
                   value="${fn:escapeXml(user.userZipcode)}"
                   class="form-control watcha-input"
                   placeholder="우편번호">
          </div>

          <div class="mb-3">
            <label class="form-label">기본주소</label>
            <input type="text"
                   name="userAddr1"
                   value="${fn:escapeXml(user.userAddr1)}"
                   class="form-control watcha-input"
                   placeholder="기본주소">
          </div>

          <div class="mb-4">
            <label class="form-label">상세주소</label>
            <input type="text"
                   name="userAddr2"
                   value="${fn:escapeXml(user.userAddr2)}"
                   class="form-control watcha-input"
                   placeholder="상세주소">
          </div>

          <button type="submit" class="btn edit-btn w-100">수정 완료</button>

          <div class="back-link">
            <a href="${ctp}/user/mypage">마이페이지로 돌아가기</a>
          </div>
        </form>

        <div class="setting-section">
          <div class="section-title">비밀번호 변경</div>
          <p class="section-desc">현재 비밀번호를 확인한 뒤 새 비밀번호로 안전하게 변경합니다.</p>

          <form id="passwordForm" action="${ctp}/user/changePw" method="post">
            <div class="mb-3">
              <label class="form-label">현재 비밀번호</label>
              <input type="password"
                     id="currentPw"
                     name="currentPw"
                     class="form-control watcha-input"
                     placeholder="현재 비밀번호 입력"
                     autocomplete="current-password"
                     maxlength="20">
            </div>

            <div class="mb-3">
              <label class="form-label">새 비밀번호</label>
              <input type="password"
                     id="newPw"
                     name="newPw"
                     class="form-control watcha-input"
                     placeholder="영문+숫자+특수문자 8~20자"
                     autocomplete="new-password"
                     maxlength="20">
              <div id="pwGuide" class="input-guide"></div>
            </div>

            <div class="mb-4">
              <label class="form-label">새 비밀번호 확인</label>
              <input type="password"
                     id="newPwCheck"
                     class="form-control watcha-input"
                     placeholder="새 비밀번호 다시 입력"
                     autocomplete="new-password"
                     maxlength="20">
              <div id="pwMatchGuide" class="input-guide"></div>
            </div>

            <button type="submit" class="btn edit-btn w-100">비밀번호 변경</button>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
