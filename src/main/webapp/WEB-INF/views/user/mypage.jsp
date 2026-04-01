<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>마이페이지 - SpringGreen8</title>
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
      --watcha-shadow:0 18px 40px rgba(0,0,0,0.08);
      --watcha-yellow:#f59e0b;
      --watcha-blue:#3b82f6;
      --watcha-green:#10b981;
      --watcha-gray:#9ca3af;
    }

    body{
      background:linear-gradient(180deg,#fbfbfc 0%, #f4f5f7 100%) !important;
      color:var(--watcha-text) !important;
      font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
    }

    a{
      text-decoration:none;
    }

    .mypage-wrap{
      padding:42px 0 60px 0;
    }

    .profile-img{
      width:96px;
      height:96px;
      object-fit:cover;
      border-radius:50%;
      border:4px solid #fff;
      box-shadow:0 8px 20px rgba(0,0,0,0.10);
      background:#f3f4f6;
    }

    .movie-poster{
      width:100%;
      height:220px;
      object-fit:cover;
      border-radius:16px;
      background:#f3f4f6;
    }

    .movie-card{
      cursor:pointer;
      transition:all 0.22s ease;
    }

    .movie-card:hover{
      transform:translateY(-4px);
    }

    .section-title{
      font-size:1.25rem;
      font-weight:800;
      color:#111827;
      margin-bottom:0;
    }

    .profile-card{
      background:var(--watcha-card);
      border:1px solid #f0f0f0;
      border-radius:28px;
      box-shadow:var(--watcha-shadow);
      overflow:hidden;
    }

    .profile-head{
      padding:34px;
      background:linear-gradient(135deg, #fff5f8 0%, #ffffff 55%, #fff8fb 100%);
    }

    .profile-name{
      font-size:1.6rem;
      font-weight:800;
      color:#111827;
      margin-bottom:4px;
    }

    .profile-email{
      font-size:14px;
      color:var(--watcha-sub);
      margin-bottom:6px;
    }

    .profile-text{
      font-size:14px;
      color:#4b5563;
      margin-bottom:4px;
      line-height:1.6;
    }

    .edit-btn{
      border-radius:999px;
      padding:10px 18px;
      font-size:14px;
      font-weight:700;
      border:1px solid #ffd1df;
      color:var(--watcha-point);
      background:#fff;
      transition:all 0.2s ease;
    }

    .edit-btn:hover{
      background:var(--watcha-point-soft);
      color:var(--watcha-point-dark);
      border-color:#ffb7cb;
    }

    .stat-card{
      background:var(--watcha-card);
      border:1px solid #f0f0f0;
      border-radius:20px;
      padding:22px 16px;
      box-shadow:0 6px 18px rgba(0,0,0,0.05);
      height:100%;
    }

    .stat-value{
      font-size:1.7rem;
      font-weight:800;
      margin-bottom:4px;
      color:#111827;
    }

    .stat-label{
      font-size:13px;
      color:var(--watcha-sub);
      font-weight:600;
    }

    .tab-wrap{
      display:flex;
      gap:10px;
      margin-bottom:24px;
      flex-wrap:wrap;
    }

    .tab-btn{
      background:#fff;
      border:1px solid #ececec;
      color:var(--watcha-sub);
      font-size:15px;
      font-weight:700;
      padding:10px 18px;
      border-radius:999px;
      cursor:pointer;
      transition:all 0.2s ease;
    }

    .tab-btn.active{
      color:#fff;
      background:var(--watcha-point);
      border-color:var(--watcha-point);
      box-shadow:0 8px 20px rgba(255,47,110,0.18);
    }

    .review-card{
      background:#fff;
      border-radius:20px;
      border:1px solid #efefef;
      box-shadow:0 6px 18px rgba(0,0,0,0.05);
    }

    .review-title{
      font-size:16px;
      font-weight:800;
      color:#111827;
      margin-bottom:6px;
    }

    .review-content{
      color:#4b5563 !important;
      line-height:1.65;
      word-break:break-word;
    }

    .review-date{
      color:var(--watcha-sub) !important;
      font-size:13px;
    }

    .poster-sm{
      width:64px;
      height:96px;
      object-fit:cover;
      border-radius:10px;
      background:#f3f4f6;
    }

    .watch-card{
      background:#fff;
      border:1px solid #efefef;
      border-radius:18px;
      padding:10px;
      box-shadow:0 6px 18px rgba(0,0,0,0.05);
      transition:all 0.22s ease;
      height:100%;
    }

    .watch-card:hover{
      transform:translateY(-4px);
      box-shadow:0 14px 28px rgba(0,0,0,0.08);
    }

    .watch-title{
      font-size:14px;
      font-weight:800;
      color:#111827;
      margin-bottom:8px;
    }

    .status-badge{
      display:inline-block;
      font-size:11px;
      padding:5px 10px;
      border-radius:999px;
      font-weight:700;
      line-height:1.2;
    }

    .empty-box{
      background:#fff;
      border:1px dashed #e5e7eb;
      border-radius:24px;
      padding:54px 20px;
      text-align:center;
    }

    .empty-box i{
      color:#d1d5db !important;
    }

    .empty-text{
      color:var(--watcha-sub);
      margin-bottom:16px;
    }

    .go-btn{
      border-radius:999px;
      padding:10px 18px;
      font-size:14px;
      font-weight:700;
      background:var(--watcha-point);
      border:none;
      color:#fff;
    }

    .go-btn:hover{
      background:var(--watcha-point-dark);
      color:#fff;
    }

    .logout-btn{
      border-radius:999px;
      padding:10px 22px;
      font-weight:700;
    }

    @media (max-width: 767px){
      .mypage-wrap{
        padding-top:24px;
      }

      .profile-head{
        padding:24px 20px;
      }

      .profile-name{
        font-size:1.35rem;
      }

      .movie-poster{
        height:200px;
      }
    }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="container mypage-wrap">

  <!-- 프로필 카드 -->
  <div class="profile-card mb-4">
    <div class="profile-head">
      <div class="row align-items-center g-3">
        <div class="col-auto">
          <img src="${ctp}/data/${user.userImg}"
		     class="profile-img"
		     onerror="this.src='https://placehold.co/96x96?text=User'">
        </div>
        <div class="col">
          <h4 class="profile-name">${user.userName}</h4>
          <p class="profile-email">${user.userEmail}</p>
          <c:if test="${not empty user.userZipcode}">
            <p class="profile-text mb-1">
              [${user.userZipcode}] ${user.userAddr1} ${user.userAddr2}
            </p>
          </c:if>
          <c:if test="${not empty user.userBio}">
            <p class="profile-text mb-0">${user.userBio}</p>
          </c:if>
        </div>
        <div class="col-12 col-md-auto text-md-end">
          <a href="${ctp}/user/edit" class="btn edit-btn">
            프로필 수정
          </a>
        </div>
      </div>
    </div>
  </div>

  <!-- 통계 -->
  <div class="row g-3 mb-4 text-center">
    <div class="col-4">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-point);">${reviewList.size()}</h3>
        <div class="stat-label">작성한 리뷰</div>
      </div>
    </div>
    <div class="col-4">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-point);">${watchList.size()}</h3>
        <div class="stat-label">찜한 영화</div>
      </div>
    </div>
    <div class="col-4">
      <div class="stat-card">
        <h3 class="stat-value" style="color:var(--watcha-yellow);">
          <c:choose>
            <c:when test="${not empty avgRating}">★ ${avgRating}</c:when>
            <c:otherwise>-</c:otherwise>
          </c:choose>
        </h3>
        <div class="stat-label">평균 별점</div>
      </div>
    </div>
  </div>

  <!-- 탭 메뉴 -->
  <div class="tab-wrap">
    <button class="tab-btn active" onclick="switchTab(this,'reviews')">
      내 리뷰 <span class="badge rounded-pill bg-light text-dark ms-1">${reviewList.size()}</span>
    </button>
    <button class="tab-btn" onclick="switchTab(this,'watchlist')">
      찜 목록 <span class="badge rounded-pill bg-light text-dark ms-1">${watchList.size()}</span>
    </button>
  </div>

  <!-- 내 리뷰 탭 -->
  <div id="tab-reviews">
    <c:choose>
      <c:when test="${not empty reviewList}">
        <c:forEach var="review" items="${reviewList}">
          <div class="review-card p-3 mb-3">
            <div class="row align-items-center g-3">
              <!-- 포스터 -->
              <div class="col-auto">
                <img src="https://image.tmdb.org/t/p/w200${review.posterPath}"
                     class="poster-sm"
                     onerror="this.src='https://via.placeholder.com/64x96?text=No'">
              </div>

              <!-- 내용 -->
              <div class="col">
                <h6 class="review-title">${review.title}</h6>
                <div class="mb-1">
                  <c:forEach begin="1" end="5" var="i">
                    <c:choose>
                      <c:when test="${i <= review.rating}">
                        <span style="color:var(--watcha-yellow);">★</span>
                      </c:when>
                      <c:otherwise>
                        <span style="color:#d1d5db;">★</span>
                      </c:otherwise>
                    </c:choose>
                  </c:forEach>
                  <span class="small ms-1" style="color:var(--watcha-yellow); font-weight:700;">${review.rating}점</span>
                </div>
                <p class="review-content small mb-0">${review.content}</p>
              </div>

              <!-- 날짜 -->
              <div class="col-12 col-md-auto text-md-end">
                <small class="review-date">
                  <fmt:formatDate value="${review.regDate}" pattern="yyyy-MM-dd"/>
                </small>
              </div>
            </div>
          </div>
        </c:forEach>
      </c:when>
      <c:otherwise>
        <div class="empty-box">
          <i class="fa fa-pencil fa-3x mb-3"></i>
          <p class="empty-text">작성한 리뷰가 없습니다.</p>
          <a href="${ctp}/movie/list" class="btn go-btn">
            영화 보러가기
          </a>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- 찜 목록 탭 -->
  <div id="tab-watchlist" style="display:none;">
    <c:choose>
      <c:when test="${not empty watchList}">
        <div class="row g-3">
          <c:forEach var="watch" items="${watchList}">
            <div class="col-6 col-md-3 col-lg-2">
              <div class="movie-card"
                   onclick="location.href='${ctp}/movie/detail/${watch.tmdbId}'">
                <div class="watch-card">
                  <img src="https://image.tmdb.org/t/p/w500${watch.posterPath}"
                       class="movie-poster mb-2"
                       onerror="this.src='https://via.placeholder.com/200x220?text=No+Image'">
                  <p class="watch-title text-truncate">${watch.title}</p>
                  <c:choose>
                    <c:when test="${watch.status == 'WANT'}">
                      <span class="status-badge text-white" style="background:var(--watcha-point);">보고싶어요</span>
                    </c:when>
                    <c:when test="${watch.status == 'WATCHED'}">
                      <span class="status-badge text-white" style="background:var(--watcha-blue);">봤어요</span>
                    </c:when>
                    <c:otherwise>
                      <span class="status-badge text-white" style="background:var(--watcha-gray);">그만볼래요</span>
                    </c:otherwise>
                  </c:choose>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:when>
      <c:otherwise>
        <div class="empty-box">
          <i class="fa fa-heart fa-3x mb-3"></i>
          <p class="empty-text">찜한 영화가 없습니다.</p>
          <a href="${ctp}/movie/list" class="btn go-btn">
            영화 보러가기
          </a>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <!-- 로그아웃 -->
  <div class="text-center mt-5">
    <a href="${ctp}/user/logout" class="btn btn-outline-danger logout-btn">로그아웃</a>
  </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
function switchTab(btn, tabName) {
    document.getElementById('tab-reviews').style.display = 'none';
    document.getElementById('tab-watchlist').style.display = 'none';
    document.querySelectorAll('.tab-btn').forEach(function(b) {
        b.classList.remove('active');
    });
    document.getElementById('tab-' + tabName).style.display = 'block';
    btn.classList.add('active');
}
</script>
</body>
</html>