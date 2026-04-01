<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>SpringGreen8 - 영화 리뷰</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    :root{
      --point:#ff2f6e;
      --point-soft:#fff0f5;
      --bg:#f6f6f7;
      --card:#ffffff;
      --text:#1f2937;
      --sub:#6b7280;
      --line:#ececec;
      --shadow:0 8px 24px rgba(0,0,0,0.08);
    }

    body{
      background:var(--bg);
      color:var(--text);
      font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
    }

    a{text-decoration:none;}

    .hero{
      position:relative;
      min-height:520px;
      border-radius:28px;
      overflow:hidden;
      margin:28px auto 0 auto;
      background:
        linear-gradient(90deg, rgba(0,0,0,0.72) 0%, rgba(0,0,0,0.48) 40%, rgba(0,0,0,0.15) 100%),
        url('https://image.tmdb.org/t/p/original${popularList[0].backdropPath}')
        center/cover no-repeat;
      display:flex;
      align-items:center;
      box-shadow:0 18px 40px rgba(0,0,0,0.18);
    }

    .hero-inner{
      width:100%;
      padding:48px;
    }

    .hero-badge{
      display:inline-block;
      padding:8px 14px;
      border-radius:999px;
      background:rgba(255,255,255,0.15);
      color:#fff;
      font-size:13px;
      font-weight:700;
      margin-bottom:16px;
      backdrop-filter:blur(5px);
    }

    .hero-title{
      font-size:3rem;
      font-weight:800;
      color:#fff;
      margin-bottom:14px;
      line-height:1.15;
    }

    .hero-meta{
      display:flex;
      flex-wrap:wrap;
      gap:8px;
      margin-bottom:16px;
    }

    .hero-meta span{
      font-size:13px;
      color:#fff;
      background:rgba(255,255,255,0.14);
      padding:6px 12px;
      border-radius:999px;
    }

    .hero-overview{
      display:-webkit-box;
      -webkit-line-clamp:4;
      -webkit-box-orient:vertical;
      overflow:hidden;
      color:rgba(255,255,255,0.9);
      max-width:620px;
      line-height:1.7;
      margin-bottom:24px;
    }

    .btn-watcha{
      border-radius:999px;
      padding:11px 24px;
      font-weight:700;
      border:none;
    }

    .btn-watcha-main{
      background:var(--point);
      color:#fff;
    }

    .btn-watcha-main:hover{
      background:#ea1e60;
      color:#fff;
    }

    .btn-watcha-sub{
      background:rgba(255,255,255,0.14);
      color:#fff;
      border:1px solid rgba(255,255,255,0.18);
    }

    .btn-watcha-sub:hover{
      background:rgba(255,255,255,0.22);
      color:#fff;
    }

    .hero-poster{
      height:300px;
      border-radius:18px;
      box-shadow:0 14px 34px rgba(0,0,0,0.28);
    }

    .main-section{
      padding:42px 0 0 0;
    }

    .section-head{
      display:flex;
      justify-content:space-between;
      align-items:end;
      margin-bottom:18px;
    }

    .section-title{
      font-size:1.45rem;
      font-weight:800;
      margin-bottom:4px;
      color:#111827;
    }

    .section-desc{
      font-size:14px;
      color:var(--sub);
    }

    .more-link{
      font-size:14px;
      color:var(--sub);
      font-weight:600;
    }

    .more-link:hover{
      color:var(--point);
    }

    .genre-chip{
      display:inline-flex;
      align-items:center;
      padding:10px 16px;
      border-radius:999px;
      background:#fff;
      color:#374151;
      border:1px solid var(--line);
      font-size:14px;
      font-weight:700;
      transition:all 0.2s;
      box-shadow:0 2px 8px rgba(0,0,0,0.03);
      white-space:nowrap;
    }

    .genre-chip:hover{
      background:var(--point-soft);
      color:var(--point);
      border-color:#ffd2df;
      transform:translateY(-1px);
    }

    .slider-wrap{
      position:relative;
    }

    .slider-viewport{
      overflow:hidden;
      border-radius:20px;
    }

    .movie-slider{
      display:flex;
      gap:16px;
      padding:4px 2px 10px 2px;
      transition:transform 0.4s ease;
      will-change:transform;
    }

    .slider-item{
      flex:0 0 185px;
      cursor:pointer;
    }

    .movie-card{
      background:var(--card);
      border-radius:18px;
      overflow:hidden;
      border:1px solid #efefef;
      box-shadow:0 4px 14px rgba(0,0,0,0.05);
      transition:all 0.22s ease;
    }

    .movie-card:hover{
      transform:translateY(-4px);
      box-shadow:var(--shadow);
    }

    .slider-poster{
      width:100%;
      height:270px;
      object-fit:cover;
      display:block;
      background:#f2f2f2;
    }

    .movie-info{
      padding:14px;
    }

    .movie-title{
      font-size:15px;
      font-weight:800;
      color:#111827;
      white-space:nowrap;
      overflow:hidden;
      text-overflow:ellipsis;
      margin-bottom:6px;
    }

    .movie-rating{
      font-size:14px;
      color:#f59e0b;
      font-weight:700;
      margin-bottom:4px;
    }

    .movie-date{
      font-size:13px;
      color:var(--sub);
      margin-bottom:0;
    }

    .slider-btn{
      position:absolute;
      top:42%;
      transform:translateY(-50%);
      z-index:10;
      width:46px;
      height:46px;
      border-radius:50%;
      background:rgba(255,255,255,0.95);
      border:1px solid #e5e7eb;
      color:#333;
      font-size:18px;
      display:flex;
      align-items:center;
      justify-content:center;
      cursor:pointer;
      box-shadow:0 10px 22px rgba(0,0,0,0.12);
      transition:all 0.2s;
    }

    .slider-btn:hover{
      background:var(--point);
      color:#fff;
      border-color:var(--point);
    }

    .slider-btn.prev{ left:-16px; }
    .slider-btn.next{ right:-16px; }

    .top-card{
      background:#fff;
      border:1px solid #efefef;
      border-radius:18px;
      padding:14px;
      box-shadow:0 4px 14px rgba(0,0,0,0.05);
      transition:all 0.22s ease;
      cursor:pointer;
    }

    .top-card:hover{
      transform:translateY(-3px);
      box-shadow:var(--shadow);
    }

    .rank-num{
      width:42px;
      height:42px;
      border-radius:12px;
      background:var(--point-soft);
      color:var(--point);
      font-size:1.05rem;
      font-weight:900;
      display:inline-flex;
      align-items:center;
      justify-content:center;
      flex-shrink:0;
      min-width:42px;
    }

    .rank-poster{
      width:58px;
      height:84px;
      object-fit:cover;
      border-radius:10px;
      background:#f2f2f2;
      flex-shrink:0;
    }

    .rank-title{
      font-size:15px;
      font-weight:800;
      color:#111827;
      margin-bottom:4px;
      white-space:nowrap;
      overflow:hidden;
      text-overflow:ellipsis;
    }

    .rank-rating{
      font-size:14px;
      color:#f59e0b;
      font-weight:700;
      margin-bottom:4px;
    }

    .rank-date{
      font-size:13px;
      color:var(--sub);
      margin-bottom:0;
    }

    @media (max-width: 991px){
      .hero{
        border-radius:22px;
        min-height:460px;
      }
      .hero-inner{
        padding:34px;
      }
      .hero-title{
        font-size:2.2rem;
      }
      .slider-btn.prev{ left:4px; }
      .slider-btn.next{ right:4px; }
    }

    @media (max-width: 767px){
      .hero{
        margin-top:0;
        border-radius:0 0 24px 24px;
        min-height:430px;
      }
      .hero-inner{
        padding:26px 20px;
      }
      .hero-title{
        font-size:1.9rem;
      }
      .hero-overview{
        -webkit-line-clamp:5;
        font-size:14px;
      }
      .slider-item{
        flex:0 0 155px;
      }
      .slider-poster{
        height:225px;
      }
      .movie-slider{
        gap:12px;
      }
    }
  </style>
</head>
<body>
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<c:if test="${not empty popularList}">
  <div class="container">
    <div class="hero">
      <div class="hero-inner">
        <div class="row align-items-center">
          <div class="col-lg-7">
            <div class="hero-badge">
              <i class="fa fa-star me-1"></i> 오늘의 추천작
            </div>

            <h1 class="hero-title">${popularList[0].title}</h1>

            <div class="hero-meta">
              <span>평균 ★ ${popularList[0].voteAverage}</span>
              <span>${popularList[0].releaseDate}</span>
              <span>인기 영화</span>
            </div>

            <p class="hero-overview">${popularList[0].overview}</p>

            <div class="d-flex gap-2 flex-wrap">
              <a href="${ctp}/movie/detail/${popularList[0].tmdbId}" class="btn btn-watcha btn-watcha-main">
                <i class="fa fa-play me-1"></i> 상세보기
              </a>
              <c:if test="${not empty sessionScope.loginUser}">
                <a href="${ctp}/movie/detail/${popularList[0].tmdbId}" class="btn btn-watcha btn-watcha-sub">
                  <i class="fa fa-heart me-1"></i> 보고싶어요
                </a>
              </c:if>
            </div>
          </div>

          <div class="col-lg-5 text-end d-none d-lg-block">
            <img src="https://image.tmdb.org/t/p/w300${popularList[0].posterPath}"
                 class="hero-poster"
                 onerror="this.style.display='none'">
          </div>
        </div>
      </div>
    </div>
  </div>
</c:if>

<div class="container py-5">

  <div class="main-section pt-0">
    <div class="section-head">
      <div>
        <div class="section-title">장르별 탐색</div>
        <div class="section-desc">취향에 맞는 영화를 골라보세요</div>
      </div>
    </div>

    <div class="d-flex flex-wrap gap-2">
      <a href="${ctp}/movie/genre?genreId=28&genreName=액션" class="genre-chip">🎬 액션</a>
      <a href="${ctp}/movie/genre?genreId=18&genreName=드라마" class="genre-chip">🎭 드라마</a>
      <a href="${ctp}/movie/genre?genreId=35&genreName=코미디" class="genre-chip">😂 코미디</a>
      <a href="${ctp}/movie/genre?genreId=27&genreName=공포" class="genre-chip">👻 공포</a>
      <a href="${ctp}/movie/genre?genreId=10749&genreName=로맨스" class="genre-chip">💕 로맨스</a>
      <a href="${ctp}/movie/genre?genreId=878&genreName=SF" class="genre-chip">🚀 SF</a>
      <a href="${ctp}/movie/genre?genreId=53&genreName=스릴러" class="genre-chip">🔪 스릴러</a>
      <a href="${ctp}/movie/genre?genreId=16&genreName=애니메이션" class="genre-chip">✨ 애니메이션</a>
      <a href="${ctp}/movie/genre?genreId=12&genreName=모험" class="genre-chip">🗺 모험</a>
      <a href="${ctp}/movie/genre?genreId=14&genreName=판타지" class="genre-chip">🧙 판타지</a>
    </div>
  </div>

  <div class="main-section">
    <div class="section-head">
      <div>
        <div class="section-title">인기 영화</div>
        <div class="section-desc">지금 가장 많이 보는 작품</div>
      </div>
      <a href="${ctp}/movie/list" class="more-link">전체보기 &rsaquo;</a>
    </div>

    <div class="slider-wrap">
      <button class="slider-btn prev" onclick="slideMove('popular', -1)">&#10094;</button>

      <div class="slider-viewport">
        <div class="movie-slider" id="popular">
          <c:forEach var="movie" items="${popularList}">
            <div class="slider-item" onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
              <div class="movie-card">
                <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                     class="slider-poster"
                     onerror="this.src='https://via.placeholder.com/185x270?text=No+Image'">
                <div class="movie-info">
                  <div class="movie-title">${movie.title}</div>
                  <div class="movie-rating">평균 ★ ${movie.voteAverage}</div>
                  <p class="movie-date">${movie.releaseDate}</p>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <button class="slider-btn next" onclick="slideMove('popular', 1)">&#10095;</button>
    </div>
  </div>

  <div class="main-section">
    <div class="section-head">
      <div>
        <div class="section-title">현재 상영중</div>
        <div class="section-desc">극장에서 볼 수 있는 최신 영화</div>
      </div>
      <a href="${ctp}/movie/list" class="more-link">전체보기 &rsaquo;</a>
    </div>

    <div class="slider-wrap">
      <button class="slider-btn prev" onclick="slideMove('nowplaying', -1)">&#10094;</button>

      <div class="slider-viewport">
        <div class="movie-slider" id="nowplaying">
          <c:forEach var="movie" items="${nowPlayingList}">
            <div class="slider-item" onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
              <div class="movie-card">
                <img src="https://image.tmdb.org/t/p/w500${movie.posterPath}"
                     class="slider-poster"
                     onerror="this.src='https://via.placeholder.com/185x270?text=No+Image'">
                <div class="movie-info">
                  <div class="movie-title">${movie.title}</div>
                  <div class="movie-rating">평균 ★ ${movie.voteAverage}</div>
                  <p class="movie-date">${movie.releaseDate}</p>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>

      <button class="slider-btn next" onclick="slideMove('nowplaying', 1)">&#10095;</button>
    </div>
  </div>

  <div class="main-section">
    <div class="section-head">
      <div>
        <div class="section-title">TOP 10</div>
        <div class="section-desc">가장 주목받는 영화 순위</div>
      </div>
    </div>

    <div class="row g-3">
      <c:forEach var="movie" items="${popularList}" end="9" varStatus="status">
        <div class="col-12 col-md-6">
          <div class="top-card" onclick="location.href='${ctp}/movie/detail/${movie.tmdbId}'">
            <div class="d-flex align-items-center gap-3">
              <span class="rank-num">${status.index + 1}</span>
              <img src="https://image.tmdb.org/t/p/w200${movie.posterPath}"
                   class="rank-poster"
                   onerror="this.src='https://via.placeholder.com/58x84?text=No'">
              <div class="overflow-hidden">
                <div class="rank-title">${movie.title}</div>
                <div class="rank-rating">평균 ★ ${movie.voteAverage}</div>
                <p class="rank-date">${movie.releaseDate}</p>
              </div>
            </div>
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>

<script>
var sliders = {};

function initSlider(id) {
    var slider = document.getElementById(id);
    if (!slider || slider.dataset.init) return;
    slider.dataset.init = 'true';

    // 기존 innerHTML 정리 후 원본만 추출
    var originals = Array.from(slider.querySelectorAll('.slider-item'));
    slider.innerHTML = '';
    originals.forEach(el => slider.appendChild(el));

    var total = originals.length;
    var itemW = originals[0].getBoundingClientRect().width;
    var gap   = parseFloat(window.getComputedStyle(slider).gap) || 16;
    var step  = itemW + gap;

    var visible = Math.max(1, Math.floor(slider.parentElement.getBoundingClientRect().width / step));

    // 앞뒤에 원본 복제 붙이기
    originals.map(el => el.cloneNode(true)).forEach(el => slider.insertBefore(el, slider.firstChild));
    originals.map(el => el.cloneNode(true)).forEach(el => slider.appendChild(el));

    // 시작 위치 = 앞 복제본 바로 다음 (실제 첫 번째)
    var cur = total;
    slider.style.transition = 'none';
    slider.style.transform = 'translateX(-' + (cur * step) + 'px)';

    sliders[id] = { slider, total, step, visible, cur, moving: false };
}

function slideMove(id, direction) {
    var s = sliders[id];
    if (!s || s.moving) return;
    s.moving = true;

    s.cur += direction * s.visible;
    s.slider.style.transition = 'transform 0.45s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
    s.slider.style.transform = 'translateX(-' + (s.cur * s.step) + 'px)';

    s.slider.addEventListener('transitionend', function handler() {
        s.slider.removeEventListener('transitionend', handler);

        var needJump = false;

        if (s.cur >= s.total * 2) {
            s.cur = s.total;
            needJump = true;
        } else if (s.cur < s.total) {
            s.cur = s.total * 2 - s.visible;
            needJump = true;
        }

        if (needJump) {
            s.slider.style.transition = 'none';
            s.slider.style.transform = 'translateX(-' + (s.cur * s.step) + 'px)';
            // ★ 핵심: 리플로우 강제 → 브라우저가 새 위치를 실제로 그린 뒤 transition 복원
            void s.slider.offsetHeight;
        }

        s.moving = false;
    }, { once: true });
}

$(document).ready(function() {
    initSlider('popular');
    initSlider('nowplaying');
});
</script>
</body>
</html>