<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${person['name']} - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    body { background: #121212; color: #fff; }

    .person-hero {
      background: linear-gradient(180deg, rgba(18,18,18,0) 0%, #121212 100%),
                  rgba(255,255,255,0.03);
      border-bottom: 1px solid rgba(255,255,255,0.08);
      padding: 60px 0 40px;
    }

    .person-photo {
      width: 160px; height: 160px; border-radius: 50%;
      object-fit: cover; border: 3px solid rgba(255,255,255,0.15);
      box-shadow: 0 12px 32px rgba(0,0,0,0.5);
    }

    .person-name {
      font-size: 2.2rem; font-weight: 800; margin-bottom: 6px;
    }

    .person-meta {
      color: #9ca3af; font-size: 0.95rem; margin-bottom: 16px;
    }

    .person-bio {
      color: #d1d5db; line-height: 1.8; max-width: 700px;
      display: -webkit-box; -webkit-line-clamp: 4;
      -webkit-box-orient: vertical; overflow: hidden;
    }

    .section-title {
      font-size: 1.2rem; font-weight: 700;
      display: flex; align-items: center; gap: 10px;
      margin-bottom: 20px;
    }

    .section-title::before {
      content: ''; width: 5px; height: 22px;
      background: linear-gradient(180deg,#34d058,#28a745);
      border-radius: 999px; display: inline-block;
    }

    .movie-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
      gap: 16px;
    }

    .movie-item {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 14px; overflow: hidden;
      text-decoration: none; color: #fff;
      transition: transform 0.18s, box-shadow 0.18s;
      display: block; cursor: pointer;
    }

    .movie-item:hover {
      transform: translateY(-4px);
      box-shadow: 0 16px 32px rgba(0,0,0,0.4);
      color: #fff;
    }

    .movie-item img {
      width: 100%; height: 200px;
      object-fit: cover; display: block; background: #1a1a1a;
    }

    .movie-item-info { padding: 10px 12px; }

    .movie-item-title {
      font-size: 13px; font-weight: 700;
      white-space: nowrap; overflow: hidden;
      text-overflow: ellipsis; margin-bottom: 3px;
    }

    .movie-item-char {
      font-size: 11px; color: #9ca3af;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }

    .movie-item-date { font-size: 11px; color: #6b7280; margin-top: 2px; }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="person-hero">
  <div class="container">
    <div class="d-flex align-items-center gap-4 flex-wrap">
      <img src="https://image.tmdb.org/t/p/w300${person['profile_path']}"
           class="person-photo"
           onerror="this.src='https://via.placeholder.com/160x160?text=?'">
      <div>
        <h1 class="person-name">${person['name']}</h1>
        <div class="person-meta">
          <c:if test="${not empty person['birthday']}">
            <span>🎂 ${person['birthday']}</span>
          </c:if>
          <c:if test="${not empty person['place_of_birth']}">
            &nbsp;·&nbsp;<span>📍 ${person['place_of_birth']}</span>
          </c:if>
          <c:if test="${not empty person['known_for_department']}">
            &nbsp;·&nbsp;<span>${person['known_for_department']}</span>
          </c:if>
        </div>
        <c:if test="${not empty person['biography']}">
          <p class="person-bio">${person['biography']}</p>
        </c:if>
      </div>
    </div>
  </div>
</div>

<div class="container py-5">
  <div class="section-title">
    출연 영화
    <span style="color:#6b7280;font-size:1rem;font-weight:400;">
      (${movies.size()}편)
    </span>
  </div>

  <c:choose>
    <c:when test="${not empty movies}">
      <div class="movie-grid">
        <c:forEach var="m" items="${movies}">
          <c:if test="${not empty m['poster_path']}">
            <div class="movie-item"
     			   onclick="location.href='${ctp}/movie/detail/${m.id}'">
              <img src="https://image.tmdb.org/t/p/w300${m['poster_path']}"
                   onerror="this.style.display='none'">
              <div class="movie-item-info">
                <div class="movie-item-title">${m['title']}</div>
                <div class="movie-item-char">${m['character']}</div>
                <div class="movie-item-date">${m['release_date']}</div>
              </div>
            </div>
          </c:if>
        </c:forEach>
      </div>
    </c:when>
    <c:otherwise>
      <p style="color:#6b7280;">출연 영화 정보가 없습니다.</p>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>