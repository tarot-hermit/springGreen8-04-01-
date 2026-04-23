<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>message</title>
</head>
<body data-message="${fn:escapeXml(message)}"
      data-url="${fn:escapeXml(ctp)}/${fn:escapeXml(url)}">
  <script>
    var pageMessage = document.body.getAttribute('data-message') || '';
    var redirectUrl = document.body.getAttribute('data-url') || '/';
    if (pageMessage) alert(pageMessage);
    location.href = redirectUrl;
  </script>
</body>
</html>
