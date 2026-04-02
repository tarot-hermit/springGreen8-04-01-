<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>500 - 서버 오류</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:'Apple SD Gothic Neo','Malgun Gothic',sans-serif;
       background:#0f0f0f;color:#e0e0e0;
       display:flex;align-items:center;justify-content:center;min-height:100vh;}
  .wrap{text-align:center;padding:40px 20px;}
  .code{font-size:120px;font-weight:800;color:#888;letter-spacing:-4px;line-height:1;}
  .title{font-size:24px;font-weight:600;margin:16px 0 8px;}
  .desc{font-size:14px;color:#888;margin-bottom:32px;}
  .btn{display:inline-block;padding:12px 28px;background:#e50914;color:#fff;
       border-radius:4px;text-decoration:none;font-size:14px;font-weight:600;}
  .btn:hover{background:#c40812;}
  .dev-info{margin-top:32px;text-align:left;background:#1a1a1a;
            border:1px solid #333;border-radius:6px;padding:16px;
            font-size:12px;color:#666;max-width:600px;word-break:break-all;}
  .dev-info summary{cursor:pointer;color:#888;margin-bottom:8px;}
</style>
</head>
<body>
  <div class="wrap">
    <div class="code">500</div>
    <div class="title">서버 오류가 발생했습니다</div>
    <div class="desc">잠시 후 다시 시도해주세요. 문제가 지속되면 관리자에게 문의하세요.</div>
    <a href="${pageContext.request.contextPath}/" class="btn">홈으로 돌아가기</a>

    <%-- 개발 환경 전용 — 운영 배포 시 아래 블록 삭제 --%>
    <% if (exception != null) { %>
    <div class="dev-info">
      <details>
        <summary>개발자 정보 (운영 배포 시 제거)</summary>
        <strong>예외:</strong> <%= exception.getClass().getName() %><br>
        <strong>메시지:</strong> <%= exception.getMessage() %>
      </details>
    </div>
    <% } %>
  </div>
</body>
</html>
