<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
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

    function previewImage(input) {
      const file = input.files[0];
      const preview = document.getElementById('profilePreview');

      if (!file) return;

      const maxSize = 2 * 1024 * 1024; // 현재 서버 제한 2MB
      if (file.size > maxSize) {
        alert('이미지는 2MB 이하만 업로드 가능합니다.');
        input.value = '';
        return;
      }

      const ext = file.name.substring(file.name.lastIndexOf('.') + 1).toLowerCase();
      if (ext !== 'jpg' && ext !== 'jpeg' && ext !== 'png' && ext !== 'gif' && ext !== 'webp') {
        alert('jpg, jpeg, png, gif, webp 파일만 업로드 가능합니다.');
        input.value = '';
        return;
      }

      const reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
      };
      reader.readAsDataURL(file);
    }
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
        <form action="${ctp}/user/edit" method="post" enctype="multipart/form-data">

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
                   accept=".jpg,.jpeg,.png,.gif,.webp"
                   onchange="previewImage(this)">
            <p class="file-guide">10MB 이하 이미지 파일만 업로드 가능합니다.</p>
          </div>

          <div class="mb-3">
            <label class="form-label">닉네임</label>
            <input type="text"
                   name="userName"
                   value="${user.userName}"
                   class="form-control watcha-input"
                   placeholder="닉네임 입력">
          </div>

          <div class="mb-3">
            <label class="form-label">이메일</label>
            <input type="email"
                   name="userEmail"
                   value="${user.userEmail}"
                   class="form-control watcha-input"
                   placeholder="이메일 입력">
          </div>

          <div class="mb-3">
            <label class="form-label">자기소개</label>
            <textarea name="userBio"
                      class="form-control watcha-input"
                      placeholder="간단한 자기소개를 입력해보세요">${user.userBio}</textarea>
          </div>

          <div class="mb-3">
            <label class="form-label">우편번호</label>
            <input type="text"
                   name="userZipcode"
                   value="${user.userZipcode}"
                   class="form-control watcha-input"
                   placeholder="우편번호">
          </div>

          <div class="mb-3">
            <label class="form-label">기본주소</label>
            <input type="text"
                   name="userAddr1"
                   value="${user.userAddr1}"
                   class="form-control watcha-input"
                   placeholder="기본주소">
          </div>

          <div class="mb-4">
            <label class="form-label">상세주소</label>
            <input type="text"
                   name="userAddr2"
                   value="${user.userAddr2}"
                   class="form-control watcha-input"
                   placeholder="상세주소">
          </div>

          <button type="submit" class="btn edit-btn w-100">수정 완료</button>

          <div class="back-link">
            <a href="${ctp}/user/mypage">마이페이지로 돌아가기</a>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>