<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="ctp" value="${pageContext.request.contextPath}"/>
<c:set var="backListUrl" value="${ctp}/movie/tv"/>
<c:set var="backListLabel" value="드라마 목록"/>
<c:if test="${not empty param.country}">
  <c:set var="backListUrl" value="${backListUrl}?country=${param.country}"/>
</c:if>
<c:if test="${param.from == 'animation'}">
  <c:set var="backListUrl" value="${ctp}/movie/animation"/>
  <c:if test="${not empty param.country}">
    <c:set var="backListUrl" value="${backListUrl}?country=${param.country}"/>
  </c:if>
  <c:set var="backListLabel" value="애니 목록"/>
</c:if>
<c:if test="${param.from == 'all'}">
  <c:set var="backListUrl" value="${ctp}/movie/all"/>
  <c:if test="${not empty param.country}">
    <c:set var="backListUrl" value="${backListUrl}?country=${param.country}"/>
  </c:if>
  <c:set var="backListLabel" value="전체 목록"/>
</c:if>
<c:if test="${param.from == 'genre' and not empty param.genreId}">
  <c:set var="backListUrl" value="${ctp}/movie/genre?genreId=${param.genreId}&genreName=${param.genreName}&page=${empty param.page ? 1 : param.page}"/>
  <c:set var="backListLabel" value="장르 목록"/>
</c:if>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${tv.title} - SpringGreen8</title>
  <%@ include file="/WEB-INF/views/common/bs5.jsp" %>
  <style>
    :root {
      --sg-bg: #101114;
      --sg-border: rgba(255,255,255,0.12);
      --sg-muted: #b6bec9;
      --sg-shadow: 0 18px 40px rgba(0,0,0,0.35);
    }
    body.bg-dark {
      background:
        radial-gradient(circle at top right, rgba(40,167,69,0.15), transparent 24%),
        radial-gradient(circle at top left, rgba(59,130,246,0.12), transparent 22%),
        var(--sg-bg) !important;
      color: #fff;
    }
    .hero {
      position: relative;
      min-height: 480px;
      background:
        linear-gradient(180deg, rgba(8,8,8,0.18) 0%, rgba(8,8,8,0.7) 60%, #101114 100%),
        url('https://image.tmdb.org/t/p/original${tv.backdropPath}') center/cover no-repeat;
    }
    .hero::before {
      content: '';
      position: absolute;
      inset: 0;
      background: linear-gradient(90deg, rgba(0,0,0,0.78) 0%, rgba(0,0,0,0.36) 46%, rgba(0,0,0,0.72) 100%);
    }
    .hero-inner {
      position: relative;
      z-index: 2;
      padding: 72px 0 40px;
    }
    .poster {
      width: 100%;
      max-width: 280px;
      border-radius: 22px;
      box-shadow: 0 20px 48px rgba(0,0,0,0.45);
      border: 1px solid rgba(255,255,255,0.10);
      background: #1d1d1d;
    }
    .page-chip,
    .meta-pill,
    .provider-badge {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      padding: 9px 14px;
      border-radius: 999px;
      background: rgba(255,255,255,0.08);
      border: 1px solid rgba(255,255,255,0.10);
      backdrop-filter: blur(10px);
    }
    .page-chip { margin-bottom: 14px; }
    .meta-wrap,
    .provider-wrap {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }
    .meta-wrap { margin: 18px 0 22px; }
    .provider-wrap { margin-top: 18px; }
    .provider-badge {
      border-radius: 16px;
      align-items: center;
    }
    .provider-logo {
      width: 34px;
      height: 34px;
      border-radius: 10px;
      object-fit: cover;
      background: rgba(255,255,255,0.08);
    }
    .provider-type,
    .muted {
      color: var(--sg-muted);
    }
    .title {
      font-size: clamp(2rem, 4vw, 3.2rem);
      font-weight: 800;
      line-height: 1.08;
      margin-bottom: 10px;
    }
    .subtitle {
      color: rgba(255,255,255,0.72);
      margin-bottom: 0;
    }
    .shell {
      margin-top: -36px;
      position: relative;
      z-index: 5;
      padding-bottom: 48px;
    }
    .card-shell {
      background: linear-gradient(180deg, rgba(255,255,255,0.06), rgba(255,255,255,0.04));
      border: 1px solid var(--sg-border);
      border-radius: 24px;
      box-shadow: var(--sg-shadow);
      backdrop-filter: blur(12px);
      padding: 24px;
    }
    .section-title {
      display: flex;
      align-items: center;
      gap: 12px;
      font-size: 1.15rem;
      font-weight: 700;
      margin-bottom: 18px;
    }
    .section-title::before {
      content: '';
      width: 6px;
      height: 24px;
      border-radius: 999px;
      background: linear-gradient(180deg, #34d058, #28a745);
    }
    .overview {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 18px;
      padding: 20px;
      line-height: 1.85;
    }
    .info-table {
      width: 100%;
    }
    .info-table td {
      padding: 12px 0;
      vertical-align: top;
    }
    .info-table tr + tr td {
      border-top: 1px solid rgba(255,255,255,0.08);
    }
    .info-table td:first-child {
      width: 110px;
      color: var(--sg-muted);
      font-weight: 700;
    }
    .cast-card {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 16px;
      overflow: hidden;
      text-align: center;
      cursor: pointer;
    }
    .cast-card img {
      width: 100%;
      height: 180px;
      object-fit: cover;
      object-position: top;
      background: #1d1d1d;
    }
    .cast-card .body {
      padding: 10px 8px 12px;
    }
    .season-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 14px;
    }
    .season-card {
      display: block;
      color: inherit;
      text-decoration: none;
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 18px;
      overflow: hidden;
      transition: transform 0.18s ease, border-color 0.18s ease, box-shadow 0.18s ease;
    }
    .season-card:hover {
      transform: translateY(-2px);
      border-color: rgba(52,208,88,0.55);
      box-shadow: 0 16px 34px rgba(0,0,0,0.22);
      color: inherit;
    }
    .season-card.active {
      border-color: rgba(52,208,88,0.85);
      box-shadow: 0 0 0 1px rgba(52,208,88,0.38);
      background: linear-gradient(180deg, rgba(52,208,88,0.16), rgba(255,255,255,0.05));
    }
    .season-poster {
      width: 100%;
      height: 132px;
      object-fit: cover;
      background: #1d1d1d;
    }
    .season-body {
      padding: 14px 16px 16px;
    }
    .season-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-top: 10px;
    }
    .season-pill {
      display: inline-flex;
      align-items: center;
      padding: 6px 10px;
      border-radius: 999px;
      background: rgba(255,255,255,0.07);
      color: var(--sg-muted);
      font-size: 12px;
      font-weight: 600;
    }
    .episode-list {
      display: grid;
      gap: 14px;
    }
    .episode-card {
      display: grid;
      grid-template-columns: 160px 1fr;
      gap: 16px;
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 18px;
      overflow: hidden;
    }
    .episode-still {
      width: 100%;
      height: 100%;
      min-height: 112px;
      object-fit: cover;
      background: #1d1d1d;
    }
    .episode-body {
      padding: 16px 16px 16px 0;
    }
    .episode-title {
      font-size: 1rem;
      font-weight: 700;
      margin-bottom: 8px;
    }
    .episode-overview {
      color: rgba(255,255,255,0.78);
      line-height: 1.7;
      margin-bottom: 10px;
    }
    .episode-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }
    @media (max-width: 991px) {
      .shell { margin-top: -16px; }
      .hero-inner { padding-top: 50px; }
    }
    @media (max-width: 767px) {
      .episode-card {
        grid-template-columns: 1fr;
      }
      .episode-body {
        padding: 0 16px 16px;
      }
    }
  </style>
</head>
<body class="bg-dark text-white">
<%@ include file="/WEB-INF/views/common/nav.jsp" %>

<div class="hero">
  <div class="container hero-inner">
    <div class="row align-items-end g-4">
      <div class="col-lg-auto text-center text-lg-start">
        <img src="https://image.tmdb.org/t/p/w500${tv.posterPath}"
             class="poster"
             onerror="this.src='https://via.placeholder.com/280x420?text=No+Image'">
      </div>
      <div class="col-lg">
        <div class="page-chip">
          <i class="fa fa-television"></i>
          <span>TV Series Detail</span>
        </div>
        <h1 class="title">${tv.title}</h1>
        <p class="subtitle">${tv.originalTitle} · ${tv.releaseDate}</p>

        <div class="meta-wrap">
          <div class="meta-pill">
            <i class="fa fa-star text-warning"></i>
            <span>TMDB</span>
            <strong>${tv.voteAverage}</strong>
          </div>
          <c:if test="${tv.runtime > 0}">
            <div class="meta-pill">
              <i class="fa fa-clock-o"></i>
              <span>회당</span>
              <strong>${tv.runtime}분</strong>
            </div>
          </c:if>
          <c:if test="${tv.seasonCount > 0}">
            <div class="meta-pill">
              <i class="fa fa-list-ol"></i>
              <span>시즌</span>
              <strong>${tv.seasonCount}</strong>
            </div>
          </c:if>
          <c:if test="${tv.episodeCount > 0}">
            <div class="meta-pill">
              <i class="fa fa-play-circle"></i>
              <span>에피소드</span>
              <strong>${tv.episodeCount}</strong>
            </div>
          </c:if>
          <c:if test="${tv.animation}">
            <div class="meta-pill">
              <i class="fa fa-magic"></i>
              <span>애니메이션</span>
            </div>
          </c:if>
        </div>

        <div class="d-flex flex-wrap gap-2">
          <a href="${backListUrl}" class="btn btn-success rounded-pill px-4">
            <i class="fa fa-arrow-left me-1"></i> ${backListLabel}
          </a>
          <a href="${ctp}/movie/search?q=${tv.title}&mediaType=tv" class="btn btn-outline-light rounded-pill px-4">
            <i class="fa fa-search me-1"></i> 검색 결과 보기
          </a>
        </div>

        <c:if test="${not empty watchProviders}">
          <div class="provider-wrap">
            <c:forEach var="provider" items="${watchProviders}">
              <div class="provider-badge">
                <img src="https://image.tmdb.org/t/p/w92${provider.logoPath}"
                     alt="${provider.providerName}"
                     class="provider-logo"
                     onerror="this.style.display='none'">
                <div>
                  <div class="fw-bold small">${provider.providerName}</div>
                  <div class="provider-type small">${provider.providerType}</div>
                </div>
              </div>
            </c:forEach>
          </div>
          <div class="muted small mt-2">KR 기준 OTT 정보, source: TMDB / JustWatch</div>
        </c:if>
      </div>
    </div>
  </div>
</div>

<div class="container shell">
  <div class="row g-4">
    <div class="col-lg-8">
      <div class="card-shell mb-4">
        <h4 class="section-title">줄거리</h4>
        <div class="overview">
          <c:choose>
            <c:when test="${not empty tv.overview}">${tv.overview}</c:when>
            <c:otherwise><span class="muted">등록된 줄거리가 없습니다.</span></c:otherwise>
          </c:choose>
        </div>
      </div>

      <c:if test="${not empty tv.seasons}">
        <div class="card-shell mb-4">
          <h4 class="section-title">시즌 선택</h4>
          <div class="season-grid">
            <c:forEach var="season" items="${tv.seasons}">
              <c:url var="seasonUrl" value="/movie/tv/${tv.tmdbId}">
                <c:param name="seasonNo" value="${season.seasonNumber}"/>
                <c:if test="${not empty param.from}">
                  <c:param name="from" value="${param.from}"/>
                </c:if>
                <c:if test="${not empty param.country}">
                  <c:param name="country" value="${param.country}"/>
                </c:if>
                <c:if test="${not empty param.genreId}">
                  <c:param name="genreId" value="${param.genreId}"/>
                </c:if>
                <c:if test="${not empty param.genreName}">
                  <c:param name="genreName" value="${param.genreName}"/>
                </c:if>
                <c:if test="${not empty param.page}">
                  <c:param name="page" value="${param.page}"/>
                </c:if>
              </c:url>
              <a href="${seasonUrl}" class="season-card ${selectedSeasonNo == season.seasonNumber ? 'active' : ''}">
                <c:choose>
                  <c:when test="${not empty season.posterPath}">
                    <img src="https://image.tmdb.org/t/p/w500${season.posterPath}"
                         alt="${season.name}"
                         class="season-poster"
                         onerror="this.src='https://via.placeholder.com/500x132?text=Season'">
                  </c:when>
                  <c:otherwise>
                    <div class="season-poster d-flex align-items-center justify-content-center">
                      <i class="fa fa-film" style="font-size:34px;color:#4b5563;"></i>
                    </div>
                  </c:otherwise>
                </c:choose>
                <div class="season-body">
                  <div class="fw-bold">${season.name}</div>
                  <div class="muted small mt-1">
                    <c:choose>
                      <c:when test="${not empty season.airDate}">${season.airDate}</c:when>
                      <c:otherwise>공개일 정보 없음</c:otherwise>
                    </c:choose>
                  </div>
                  <div class="season-meta">
                    <span class="season-pill">시즌 ${season.seasonNumber}</span>
                    <span class="season-pill">${season.episodeCount > 0 ? season.episodeCount : '-'}화</span>
                  </div>
                </div>
              </a>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <c:if test="${not empty videos}">
        <div class="card-shell mb-4">
          <h4 class="section-title">
            <c:choose>
              <c:when test="${not empty seasonVideos and not empty selectedSeason}">${selectedSeason.name} 예고편 / 영상</c:when>
              <c:when test="${videoFallbackLabel == 'season1'}">시즌 1 예고편 / 영상</c:when>
              <c:otherwise>예고편 / 영상</c:otherwise>
            </c:choose>
          </h4>
          <c:if test="${empty seasonVideos and not empty selectedSeason}">
            <div class="muted small mb-3">
              <c:choose>
                <c:when test="${videoFallbackLabel == 'season1'}">${selectedSeason.name} 전용 영상이 없어 시즌 1 영상을 보여주고 있습니다.</c:when>
                <c:otherwise>${selectedSeason.name} 전용 영상이 없어 시리즈 전체 영상을 보여주고 있습니다.</c:otherwise>
              </c:choose>
            </div>
          </c:if>
          <div class="row g-3">
            <c:forEach var="video" items="${videos}">
              <div class="col-12 col-md-6">
                <div style="position:relative;padding-bottom:56.25%;border-radius:16px;overflow:hidden;background:#000;">
                  <iframe
                    src="https://www.youtube.com/embed/${video.key}"
                    title="${video.name}"
                    style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;"></iframe>
                </div>
                <p class="mt-2 mb-0 muted small">${video.name}</p>
              </div>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <c:if test="${not empty selectedSeason}">
        <div class="card-shell mb-4">
          <h4 class="section-title">${selectedSeason.name}</h4>
          <div class="overview mb-4">
            <c:choose>
              <c:when test="${not empty selectedSeason.overview}">${selectedSeason.overview}</c:when>
              <c:otherwise><span class="muted">시즌 소개가 아직 없습니다.</span></c:otherwise>
            </c:choose>
          </div>

          <c:choose>
            <c:when test="${not empty selectedSeason.episodes}">
              <div class="episode-list">
                <c:forEach var="episode" items="${selectedSeason.episodes}">
                  <div class="episode-card">
                    <c:choose>
                      <c:when test="${not empty episode.stillPath}">
                        <img src="https://image.tmdb.org/t/p/w500${episode.stillPath}"
                             alt="${episode.name}"
                             class="episode-still"
                             onerror="this.src='https://via.placeholder.com/500x281?text=Episode'">
                      </c:when>
                      <c:otherwise>
                        <div class="episode-still d-flex align-items-center justify-content-center">
                          <i class="fa fa-play-circle" style="font-size:42px;color:#4b5563;"></i>
                        </div>
                      </c:otherwise>
                    </c:choose>
                    <div class="episode-body">
                      <div class="episode-title">EP ${episode.episodeNumber}. ${episode.name}</div>
                      <div class="episode-overview">
                        <c:choose>
                          <c:when test="${not empty episode.overview}">${episode.overview}</c:when>
                          <c:otherwise><span class="muted">에피소드 설명이 없습니다.</span></c:otherwise>
                        </c:choose>
                      </div>
                      <div class="episode-meta">
                        <span class="season-pill">
                          <c:choose>
                            <c:when test="${not empty episode.airDate}">${episode.airDate}</c:when>
                            <c:otherwise>공개일 미정</c:otherwise>
                          </c:choose>
                        </span>
                        <c:if test="${episode.runtime > 0}">
                          <span class="season-pill">${episode.runtime}분</span>
                        </c:if>
                        <c:if test="${episode.voteAverage > 0}">
                          <span class="season-pill">TMDB ${episode.voteAverage}</span>
                        </c:if>
                      </div>
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div class="muted">선택한 시즌의 에피소드 정보가 아직 없습니다.</div>
            </c:otherwise>
          </c:choose>
        </div>
      </c:if>

      <c:if test="${not empty cast}">
        <div class="card-shell mb-4">
          <h4 class="section-title">출연진</h4>
          <div class="row g-3">
            <c:forEach var="actor" items="${cast}">
              <div class="col-6 col-md-4 col-lg-3">
                <div class="cast-card" onclick="location.href='${ctp}/movie/person/${actor.id}'">
                  <c:choose>
                    <c:when test="${not empty actor['profile_path']}">
                      <img src="https://image.tmdb.org/t/p/w185${actor['profile_path']}"
                           onerror="this.src='https://via.placeholder.com/185x180?text=No+Image'">
                    </c:when>
                    <c:otherwise>
                      <div style="height:180px;background:#2a2a2a;display:flex;align-items:center;justify-content:center;">
                        <i class="fa fa-user" style="font-size:48px;color:#555;"></i>
                      </div>
                    </c:otherwise>
                  </c:choose>
                  <div class="body">
                    <div class="fw-bold small text-truncate">${actor['name']}</div>
                    <div class="muted small text-truncate">${actor['character']}</div>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>
        </div>
      </c:if>
    </div>

    <div class="col-lg-4">
      <div class="card-shell">
        <h4 class="section-title">시리즈 정보</h4>
        <table class="info-table">
          <tr>
            <td>제목</td>
            <td>${tv.title}</td>
          </tr>
          <tr>
            <td>원제</td>
            <td>${tv.originalTitle}</td>
          </tr>
          <tr>
            <td>첫 공개일</td>
            <td>${tv.releaseDate}</td>
          </tr>
          <tr>
            <td>시즌</td>
            <td>${tv.seasonCount > 0 ? tv.seasonCount : '-'}</td>
          </tr>
          <tr>
            <td>에피소드</td>
            <td>${tv.episodeCount > 0 ? tv.episodeCount : '-'}</td>
          </tr>
          <tr>
            <td>국가</td>
            <td>
              <c:choose>
                <c:when test="${not empty tv.originCountries}">
                  <c:forEach var="countryCode" items="${tv.originCountries}" varStatus="st">
                    ${countryCode}<c:if test="${not st.last}">, </c:if>
                  </c:forEach>
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </td>
          </tr>
          <tr>
            <td>OTT</td>
            <td>
              <c:choose>
                <c:when test="${not empty watchProviders}">
                  <c:forEach var="provider" items="${watchProviders}" varStatus="st">
                    ${provider.providerName}<c:if test="${not st.last}">, </c:if>
                  </c:forEach>
                </c:when>
                <c:otherwise>-</c:otherwise>
              </c:choose>
            </td>
          </tr>
        </table>
      </div>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jsp" %>
</body>
</html>
