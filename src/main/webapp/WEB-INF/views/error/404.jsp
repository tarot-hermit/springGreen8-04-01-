<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>404 - 페이지를 찾을 수 없습니다</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:'Apple SD Gothic Neo','Malgun Gothic',sans-serif;
       background:#0f0f0f;color:#e0e0e0;
       display:flex;align-items:center;justify-content:center;min-height:100vh;}
  .wrap{text-align:center;padding:40px 20px;}
  .code{font-size:120px;font-weight:800;color:#e50914;letter-spacing:-4px;line-height:1;}
  .title{font-size:24px;font-weight:600;margin:16px 0 8px;}
  .desc{font-size:14px;color:#888;margin-bottom:32px;}
  .btn{display:inline-block;padding:12px 28px;background:#e50914;color:#fff;
       border-radius:4px;text-decoration:none;font-size:14px;font-weight:600;}
  .btn:hover{background:#c40812;}
</style>
</head>
<body>
  <div class="wrap">
    <div class="code">404</div>
    <div class="title">페이지를 찾을 수 없습니다</div>
    <div class="desc">요청하신 페이지가 삭제되었거나 주소가 변경되었습니다.</div>
    <a href="${pageContext.request.contextPath}/" class="btn">홈으로 돌아가기</a>
  </div>
</body>
</html>
