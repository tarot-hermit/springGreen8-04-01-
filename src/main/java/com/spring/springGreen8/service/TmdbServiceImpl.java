package com.spring.springGreen8.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientResponseException;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.spring.springGreen8.dao.MediaVideoCacheDAO;
import com.spring.springGreen8.vo.MediaContentVO;
import com.spring.springGreen8.vo.MediaSearchResultVO;
import com.spring.springGreen8.vo.MediaVideoCacheVO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.OttProviderVO;
import com.spring.springGreen8.vo.EpisodeVO;
import com.spring.springGreen8.vo.SeasonVO;

@Service
public class TmdbServiceImpl implements TmdbService {

    private static final Logger log = LoggerFactory.getLogger(TmdbServiceImpl.class);
    private static final String BASE_URL = "https://api.themoviedb.org/3";
    private static final String LANG = "ko-KR";
    private static final String YOUTUBE_REGION = "KR";
    private static final ZoneId YOUTUBE_QUOTA_ZONE = ZoneId.of("America/Los_Angeles");
    private static final String TMDB_VIDEO_CACHE_SOURCE = "TMDB_V3";
    private static final String YOUTUBE_VIDEO_CACHE_SOURCE = "YOUTUBE_V3";
    private static final int TMDB_PAGE_SIZE = 20;
    private static final int COMBINED_PAGE_SIZE = 24;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private MediaVideoCacheDAO mediaVideoCacheDAO;

    @Value("${tmdb.api.key:}")
    private String apiKey;

    @Value("${youtube.api.key:}")
    private String youtubeApiKey;

    private volatile long youtubeQuotaBlockedUntilEpochMs = 0L;

    private String resolveApiKey() {
        if (apiKey != null && !apiKey.trim().isEmpty()) {
            return apiKey.trim();
        }

        try {
            Properties props = new Properties();
            try (java.io.InputStream in =
                    Thread.currentThread().getContextClassLoader().getResourceAsStream("app.properties")) {
                if (in != null) {
                    props.load(in);
                    apiKey = props.getProperty("tmdb.api.key", "").trim();
                }
            }
        } catch (Exception e) {
            log.warn("Failed to load tmdb.api.key from app.properties", e);
        }
        return apiKey == null ? "" : apiKey.trim();
    }

    private String resolveYoutubeApiKey() {
        return youtubeApiKey == null ? "" : youtubeApiKey.trim();
    }

    private boolean isYoutubeUrl(String url) {
        return url != null
                && (url.contains("youtube.googleapis.com")
                || url.contains("www.googleapis.com/youtube/"));
    }

    private boolean isYoutubeQuotaExceeded(String responseBody) {
        return responseBody != null && responseBody.contains("quotaExceeded");
    }

    private long nextYoutubeQuotaResetEpochMs() {
        ZonedDateTime now = ZonedDateTime.now(YOUTUBE_QUOTA_ZONE);
        ZonedDateTime nextReset = now.toLocalDate().plusDays(1).atStartOfDay(YOUTUBE_QUOTA_ZONE);
        return nextReset.toInstant().toEpochMilli();
    }

    private boolean isYoutubeQuotaBlocked() {
        return Instant.now().toEpochMilli() < youtubeQuotaBlockedUntilEpochMs;
    }

    private void blockYoutubeUntilReset() {
        long nextReset = nextYoutubeQuotaResetEpochMs();
        if (youtubeQuotaBlockedUntilEpochMs < nextReset) {
            youtubeQuotaBlockedUntilEpochMs = nextReset;
            log.warn("YouTube fallback disabled until next quota reset at {}", Instant.ofEpochMilli(nextReset));
        }
    }

    @SuppressWarnings("unchecked")
    private List<MovieVO> parseMovieList(Map<String, Object> response) {
        List<MovieVO> list = new ArrayList<>();
        if (response == null) return list;

        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
        if (results == null) return list;

        for (Map<String, Object> item : results) {
            MovieVO vo = new MovieVO();
            vo.setTmdbId(item.get("id") != null ? ((Number) item.get("id")).intValue() : 0);
            vo.setTitle(item.get("title") != null ? (String) item.get("title") : "");
            vo.setOriginalTitle(item.get("original_title") != null ? (String) item.get("original_title") : "");
            vo.setOverview(item.get("overview") != null ? (String) item.get("overview") : "");
            vo.setPosterPath(item.get("poster_path") != null ? (String) item.get("poster_path") : "");
            vo.setBackdropPath(item.get("backdrop_path") != null ? (String) item.get("backdrop_path") : "");
            vo.setReleaseDate(item.get("release_date") != null ? (String) item.get("release_date") : "");
            vo.setVoteAverage(item.get("vote_average") != null ? ((Number) item.get("vote_average")).doubleValue() : 0);
            vo.setPopularity(item.get("popularity") != null ? ((Number) item.get("popularity")).doubleValue() : 0);
            list.add(vo);
        }
        return list;
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> getForMap(String url) {
        if (isYoutubeUrl(url) && isYoutubeQuotaBlocked()) {
            return null;
        }
        try {
            return restTemplate.getForObject(url, Map.class);
        } catch (RestClientResponseException e) {
            String safeUrl = maskSensitiveUrl(url);
            String responseBody = e.getResponseBodyAsString();
            if (isYoutubeUrl(url) && (e.getRawStatusCode() == 403 || isYoutubeQuotaExceeded(responseBody))) {
                blockYoutubeUntilReset();
            }
            if (responseBody == null || responseBody.isBlank()) {
                log.warn("API request failed: " + safeUrl + " status=" + e.getRawStatusCode() + " " + e.getStatusText(), e);
            } else {
                log.warn("API request failed: " + safeUrl + " status=" + e.getRawStatusCode() + " " + e.getStatusText() + " body=" + responseBody, e);
            }
            return null;
        } catch (RestClientException e) {
            log.warn("API request failed: {}", maskSensitiveUrl(url), e);
            return null;
        }
    }

    private String maskSensitiveUrl(String url) {
        if (url == null || url.isBlank()) return "";
        return url.replaceAll("([?&]key=)[^&]+", "$1***");
    }

    private String encoded(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private boolean isAllCountry(String countryCode) {
        return countryCode == null || countryCode.isBlank() || "ALL".equalsIgnoreCase(countryCode);
    }

    private String normalizedCountry(String countryCode) {
        return isAllCountry(countryCode) ? "KR" : countryCode.toUpperCase();
    }

    private int pagesNeededFor(int itemCount) {
        return Math.max(1, (itemCount + TMDB_PAGE_SIZE - 1) / TMDB_PAGE_SIZE);
    }

    private String buildGenreDiscoverUrl(String mediaType, int genreId, int page) {
        StringBuilder url = new StringBuilder(BASE_URL)
                .append("/discover/")
                .append(mediaType)
                .append("?api_key=").append(resolveApiKey())
                .append("&language=").append(LANG)
                .append("&with_genres=").append(genreId)
                .append("&page=").append(page)
                .append("&sort_by=popularity.desc")
                .append("&include_adult=false");

        if ("movie".equals(mediaType)) {
            url.append("&region=KR");
        }
        return url.toString();
    }

    private String buildMultiSearchUrl(String query, int page) {
        return BASE_URL + "/search/multi?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&query=" + encoded(query)
                + "&page=" + page
                + "&include_adult=false";
    }

    private String buildTvSearchUrl(String query, int page) {
        return BASE_URL + "/search/tv?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&query=" + encoded(query)
                + "&page=" + page
                + "&include_adult=false";
    }

    private String buildOnTheAirTvUrl(int page) {
        return BASE_URL + "/tv/on_the_air?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&page=" + page;
    }

    private boolean hasYoutubeApiKey() {
        return !resolveYoutubeApiKey().isEmpty() && !isYoutubeQuotaBlocked();
    }

    private String buildYoutubeSearchUrl(String query) {
        return "https://www.googleapis.com/youtube/v3/search?part=snippet"
                + "&type=video"
                + "&maxResults=10"
                + "&videoEmbeddable=true"
                + "&videoSyndicated=true"
                + "&key=" + resolveYoutubeApiKey()
                + "&q=" + encoded(query);
    }

    private String buildYoutubeVideoDetailsUrl(List<String> videoIds) {
        return "https://www.googleapis.com/youtube/v3/videos?part=status,contentDetails"
                + "&key=" + resolveYoutubeApiKey()
                + "&id=" + encoded(String.join(",", videoIds));
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> searchYoutubeVideos(String query) {
        List<Map<String, Object>> videos = new ArrayList<>();
        if (!hasYoutubeApiKey() || isYoutubeQuotaBlocked() || query == null || query.isBlank()) return videos;

        Map<String, Object> response = getForMap(buildYoutubeSearchUrl(query));
        if (response == null) return videos;

        List<Map<String, Object>> items = (List<Map<String, Object>>) response.get("items");
        if (items == null) return videos;

        for (Map<String, Object> item : items) {
            Object idObj = item.get("id");
            Object snippetObj = item.get("snippet");
            if (!(idObj instanceof Map<?, ?>) || !(snippetObj instanceof Map<?, ?>)) continue;

            Map<String, Object> id = (Map<String, Object>) idObj;
            Map<String, Object> snippet = (Map<String, Object>) snippetObj;
            String videoId = stringValue(id.get("videoId"));
            if (videoId.isEmpty()) continue;

            Map<String, Object> video = new LinkedHashMap<>();
            video.put("key", videoId);
            video.put("name", stringValue(snippet.get("title")));
            video.put("channelTitle", stringValue(snippet.get("channelTitle")));
            video.put("site", "YouTube");
            video.put("type", "YouTube Search");
            videos.add(video);
        }
        return videos;
    }

    private List<String> youtubeTitleCandidates(MediaContentVO content) {
        List<String> titles = new ArrayList<>();
        if (content == null) return titles;
        if (content.getTitle() != null && !content.getTitle().isBlank()) {
            titles.add(content.getTitle().trim());
        }
        if (content.getOriginalTitle() != null && !content.getOriginalTitle().isBlank()) {
            String originalTitle = content.getOriginalTitle().trim();
            if (!titles.contains(originalTitle)) {
                titles.add(originalTitle);
            }
        }
        return titles;
    }

    private String normalizedYoutubeText(String value) {
        return value == null ? "" : value.toLowerCase().replaceAll("[^\\p{L}\\p{N}]+", "");
    }

    private boolean containsAnyIgnoreCase(String source, String... keywords) {
        if (source == null || source.isBlank()) return false;
        String lower = source.toLowerCase();
        for (String keyword : keywords) {
            if (keyword != null && !keyword.isBlank() && lower.contains(keyword.toLowerCase())) {
                return true;
            }
        }
        return false;
    }

    private boolean hasStrongYoutubeTitleMatch(String candidateText, List<String> titleCandidates) {
        String normalizedCandidate = normalizedYoutubeText(candidateText);
        if (normalizedCandidate.isEmpty()) return false;

        for (String title : titleCandidates) {
            String normalizedTitle = normalizedYoutubeText(title);
            if (normalizedTitle.length() >= 2 && normalizedCandidate.contains(normalizedTitle)) {
                return true;
            }
        }
        return false;
    }

    private boolean isTrailerLikeYoutubeTitle(String title) {
        return containsAnyIgnoreCase(title,
                "official trailer", "trailer", "official teaser", "teaser", "main trailer",
                "official preview", "preview", "예고편", "티저", "메인 예고편", "본예고",
                "pv", "promotion video");
    }

    private boolean isExcludedYoutubeResult(String title, String channelTitle) {
        return containsAnyIgnoreCase(title,
                "#shorts", "shorts", "쇼츠", "reaction", "리액션", "review", "리뷰",
                "ost", "opening", "ending", "op ", " ed", "amv", "edit", "meme",
                "clip", "scene", "recap", "explained", "analysis", "interview",
                "fan made", "fanmade", "cover", "music video", "mv", "full episode")
            || containsAnyIgnoreCase(channelTitle, "#shorts", "shorts", "쇼츠");
    }

    private int seasonKeywordScore(String title, Integer seasonNo) {
        if (title == null || title.isBlank() || seasonNo == null) return 0;

        int score = 0;
        if (containsAnyIgnoreCase(title,
                "season " + seasonNo,
                "season" + seasonNo,
                "시즌 " + seasonNo,
                "시즌" + seasonNo,
                seasonNo + "기",
                "part " + seasonNo,
                "cour " + seasonNo)) {
            score += 3;
        }
        if (seasonNo == 1 && containsAnyIgnoreCase(title, "1st season", "season one")) {
            score += 2;
        }
        return score;
    }

    private int youtubeResultScore(Map<String, Object> video, List<String> titleCandidates, Integer seasonNo) {
        String title = stringValue(video.get("name"));
        String channelTitle = stringValue(video.get("channelTitle"));
        if (isExcludedYoutubeResult(title, channelTitle)) return Integer.MIN_VALUE;

        boolean titleMatch = hasStrongYoutubeTitleMatch(title, titleCandidates);
        boolean channelMatch = hasStrongYoutubeTitleMatch(channelTitle, titleCandidates);
        boolean trailerLike = isTrailerLikeYoutubeTitle(title);

        if (!titleMatch && !channelMatch) return Integer.MIN_VALUE;
        if (!trailerLike) return Integer.MIN_VALUE;

        int score = 0;
        if (titleMatch) score += 6;
        if (channelMatch) score += 2;
        if (trailerLike) score += 4;
        if (containsAnyIgnoreCase(title, "official")) score += 1;
        if (containsAnyIgnoreCase(channelTitle, "official", "netflix", "crunchyroll", "aniplex", "toho")) score += 1;
        score += seasonKeywordScore(title, seasonNo);
        return score;
    }

    @SuppressWarnings("unchecked")
    private Set<String> fetchPlayableYoutubeVideoKeys(List<Map<String, Object>> videos) {
        Set<String> playableKeys = new LinkedHashSet<>();
        if (!hasYoutubeApiKey() || isYoutubeQuotaBlocked() || videos == null || videos.isEmpty()) return playableKeys;

        List<String> videoIds = new ArrayList<>();
        for (Map<String, Object> video : videos) {
            String key = stringValue(video.get("key"));
            if (!key.isEmpty() && !videoIds.contains(key)) {
                videoIds.add(key);
            }
        }
        if (videoIds.isEmpty()) return playableKeys;

        Map<String, Object> response = getForMap(buildYoutubeVideoDetailsUrl(videoIds));
        if (response == null) {
            return playableKeys;
        }

        List<Map<String, Object>> items = (List<Map<String, Object>>) response.get("items");
        if (items == null) return playableKeys;

        for (Map<String, Object> item : items) {
            String key = stringValue(item.get("id"));
            if (key.isEmpty()) continue;

            Object statusObj = item.get("status");
            Object contentDetailsObj = item.get("contentDetails");
            if (!(statusObj instanceof Map<?, ?>)) continue;

            Map<String, Object> status = (Map<String, Object>) statusObj;
            if (!Boolean.TRUE.equals(status.get("embeddable"))) continue;

            String privacyStatus = stringValue(status.get("privacyStatus"));
            if (!"public".equalsIgnoreCase(privacyStatus) && !"unlisted".equalsIgnoreCase(privacyStatus)) continue;

            String uploadStatus = stringValue(status.get("uploadStatus"));
            if (!uploadStatus.isEmpty() && !"processed".equalsIgnoreCase(uploadStatus)) continue;

            if (contentDetailsObj instanceof Map<?, ?>) {
                Map<String, Object> contentDetails = (Map<String, Object>) contentDetailsObj;
                Object regionRestrictionObj = contentDetails.get("regionRestriction");
                if (regionRestrictionObj instanceof Map<?, ?>) {
                    Map<String, Object> regionRestriction = (Map<String, Object>) regionRestrictionObj;

                    Object allowedObj = regionRestriction.get("allowed");
                    if (allowedObj instanceof List<?>) {
                        List<String> allowed = new ArrayList<>();
                        for (Object region : (List<Object>) allowedObj) {
                            if (region != null) allowed.add(String.valueOf(region).toUpperCase());
                        }
                        if (!allowed.isEmpty() && !allowed.contains(YOUTUBE_REGION)) continue;
                    }

                    Object blockedObj = regionRestriction.get("blocked");
                    if (blockedObj instanceof List<?>) {
                        for (Object region : (List<Object>) blockedObj) {
                            if (YOUTUBE_REGION.equalsIgnoreCase(stringValue(region))) {
                                key = "";
                                break;
                            }
                        }
                        if (key.isEmpty()) continue;
                    }
                }
            }

            playableKeys.add(key);
        }
        return playableKeys;
    }

    private List<Map<String, Object>> distinctYoutubeVideos(List<Map<String, Object>> videos) {
        if (videos == null || videos.isEmpty()) return new ArrayList<>();

        List<Map<String, Object>> filtered = new ArrayList<>();
        Set<String> seenKeys = new LinkedHashSet<>();
        for (Map<String, Object> video : videos) {
            String key = stringValue(video.get("key"));
            if (key.isEmpty() || !seenKeys.add(key)) continue;
            filtered.add(video);
        }
        return filtered;
    }

    private List<Map<String, Object>> filterPlayableYoutubeVideos(List<Map<String, Object>> videos) {
        return filterPlayableYoutubeVideos(videos, false);
    }

    private List<Map<String, Object>> filterPlayableYoutubeVideos(List<Map<String, Object>> videos, boolean allowUnverifiedWhenQuotaBlocked) {
        if (videos == null || videos.isEmpty()) return new ArrayList<>();

        Set<String> playableKeys = fetchPlayableYoutubeVideoKeys(videos);
        if (playableKeys.isEmpty()) {
            if (allowUnverifiedWhenQuotaBlocked && isYoutubeQuotaBlocked()) {
                return distinctYoutubeVideos(videos);
            }
            return new ArrayList<>();
        }

        List<Map<String, Object>> filtered = new ArrayList<>();
        Set<String> seenKeys = new LinkedHashSet<>();
        for (Map<String, Object> video : videos) {
            String key = stringValue(video.get("key"));
            if (key.isEmpty() || !playableKeys.contains(key) || !seenKeys.add(key)) continue;
            filtered.add(video);
        }
        return filtered;
    }

    private List<Map<String, Object>> rankYoutubeFallbackVideos(List<Map<String, Object>> videos, List<String> titleCandidates, Integer seasonNo) {
        List<Map<String, Object>> ranked = new ArrayList<>();
        for (Map<String, Object> video : videos) {
            int score = youtubeResultScore(video, titleCandidates, seasonNo);
            if (score == Integer.MIN_VALUE) continue;

            Map<String, Object> copy = new LinkedHashMap<>(video);
            copy.put("_score", score);
            ranked.add(copy);
        }

        ranked.sort((a, b) -> Integer.compare(intValue(b.get("_score")), intValue(a.get("_score"))));

        List<Map<String, Object>> selected = new ArrayList<>();
        Set<String> seenKeys = new LinkedHashSet<>();
        for (Map<String, Object> video : ranked) {
            String key = stringValue(video.get("key"));
            if (key.isEmpty() || !seenKeys.add(key)) continue;
            video.remove("_score");
            selected.add(video);
            if (selected.size() == 3) break;
        }
        return selected;
    }

    private List<Map<String, Object>> selectYoutubeFallbackVideos(List<Map<String, Object>> videos, List<String> titleCandidates, Integer seasonNo) {
        return filterPlayableYoutubeVideos(rankYoutubeFallbackVideos(videos, titleCandidates, seasonNo));
    }

    private List<Map<String, Object>> searchYoutubeFallbackCandidates(List<String> titleCandidates, Integer seasonNo, String... queries) {
        List<Map<String, Object>> candidates = new ArrayList<>();
        Set<String> seenKeys = new LinkedHashSet<>();
        for (String query : queries) {
            if (isYoutubeQuotaBlocked()) break;
            if (query == null || query.trim().isEmpty()) continue;
            List<Map<String, Object>> videos = searchYoutubeVideos(query);
            if (isYoutubeQuotaBlocked()) break;
            for (Map<String, Object> video : videos) {
                String key = stringValue(video.get("key"));
                if (key.isEmpty() || !seenKeys.add(key)) continue;
                candidates.add(video);
            }
        }
        return selectYoutubeFallbackVideos(candidates, titleCandidates, seasonNo);
    }

    private List<Map<String, Object>> getCachedVideoList(String mediaType, int tmdbId, Integer seasonNo, String sourceType) {
        if (mediaVideoCacheDAO == null) return new ArrayList<>();

        try {
            List<MediaVideoCacheVO> cached = mediaVideoCacheDAO.selectVideoCache(mediaType, tmdbId, seasonNo);
            List<Map<String, Object>> videos = new ArrayList<>();
            for (MediaVideoCacheVO item : cached) {
                if (sourceType != null && !sourceType.equalsIgnoreCase(item.getSourceType())) continue;
                String videoKey = item.getVideoKey();
                if (videoKey == null || videoKey.isBlank()) continue;

                Map<String, Object> video = new LinkedHashMap<>();
                video.put("key", videoKey);
                video.put("name", item.getVideoName());
                video.put("site", item.getVideoSite());
                video.put("type", item.getVideoType());
                videos.add(video);
            }
            return videos;
        } catch (Exception e) {
            log.warn("Failed to read video cache. mediaType=" + mediaType + ", tmdbId=" + tmdbId + ", seasonNo=" + seasonNo, e);
            return new ArrayList<>();
        }
    }

    private void saveVideoCache(String mediaType, int tmdbId, Integer seasonNo, String sourceType, List<Map<String, Object>> videos) {
        if (mediaVideoCacheDAO == null || videos == null || videos.isEmpty()) return;

        try {
            mediaVideoCacheDAO.deleteVideoCache(mediaType, tmdbId, seasonNo);

            Set<String> savedKeys = new LinkedHashSet<>();
            int displayOrder = 1;
            for (Map<String, Object> video : videos) {
                String videoKey = stringValue(video.get("key"));
                if (videoKey.isEmpty() || !savedKeys.add(videoKey)) continue;

                MediaVideoCacheVO cache = new MediaVideoCacheVO();
                cache.setTmdbId(tmdbId);
                cache.setMediaType(mediaType);
                cache.setSeasonNo(seasonNo);
                cache.setSourceType(sourceType);
                cache.setVideoKey(videoKey);
                cache.setVideoName(stringValue(video.get("name")));
                cache.setVideoSite(stringValue(video.get("site")));
                cache.setVideoType(stringValue(video.get("type")));
                cache.setDisplayOrder(displayOrder++);
                mediaVideoCacheDAO.insertVideoCache(cache);
            }
        } catch (Exception e) {
            log.warn("Failed to save video cache. mediaType=" + mediaType + ", tmdbId=" + tmdbId + ", seasonNo=" + seasonNo, e);
        }
    }

    private List<String> buildSeriesYoutubeQueries(List<String> titleCandidates) {
        List<String> queries = new ArrayList<>();
        for (String title : titleCandidates) {
            if (title == null || title.isBlank()) continue;
            queries.add(title + " official trailer");
            queries.add(title + " trailer");
            queries.add(title + " teaser");
            queries.add(title + " official teaser");
        }
        return queries;
    }

    private List<String> buildSeasonYoutubeQueries(List<String> titleCandidates, int seasonNo, SeasonVO season) {
        List<String> queries = new ArrayList<>();
        String seasonName = season == null ? "" : stringValue(season.getName()).trim();
        boolean hasSpecificSeasonName = !seasonName.isBlank()
                && !containsAnyIgnoreCase(seasonName,
                        "season " + seasonNo, "season" + seasonNo,
                        "시즌 " + seasonNo, "시즌" + seasonNo);

        for (String title : titleCandidates) {
            if (title == null || title.isBlank()) continue;

            queries.add(title + " season " + seasonNo + " official trailer");
            queries.add(title + " season " + seasonNo + " trailer");
            queries.add(title + " season " + seasonNo + " teaser");
            queries.add(title + " part " + seasonNo + " trailer");

            if (seasonNo == 1) {
                queries.add(title + " 1st season trailer");
                queries.add(title + " season one trailer");
            }

            if (seasonNo == 0 || containsAnyIgnoreCase(seasonName, "special", "specials", "스페셜")) {
                queries.add(title + " special trailer");
                queries.add(title + " special teaser");
            }

            if (hasSpecificSeasonName) {
                queries.add(title + " " + seasonName + " trailer");
                queries.add(title + " " + seasonName + " teaser");
            }
        }
        return queries;
    }

    private boolean matchesRequestedMediaType(MediaContentVO content, String mediaType) {
        if (content == null) return false;
        if (mediaType == null || mediaType.isBlank() || "all".equalsIgnoreCase(mediaType)) return true;
        if ("movie".equalsIgnoreCase(mediaType)) return "movie".equals(content.getMediaType());
        if ("tv".equalsIgnoreCase(mediaType)) return "tv".equals(content.getMediaType());
        if ("animation".equalsIgnoreCase(mediaType)) return content.isAnimation();
        return true;
    }

    @SuppressWarnings("unchecked")
    private List<MediaContentVO> parseMediaList(Map<String, Object> response, String forcedMediaType) {
        List<MediaContentVO> list = new ArrayList<>();
        if (response == null) return list;

        List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
        if (results == null) return list;

        for (Map<String, Object> item : results) {
            list.add(parseMediaContent(item, forcedMediaType));
        }
        return list;
    }

    private String stringValue(Object value) {
        return value == null ? "" : String.valueOf(value);
    }

    private int intValue(Object value) {
        return value instanceof Number ? ((Number) value).intValue() : 0;
    }

    private double doubleValue(Object value) {
        return value instanceof Number ? ((Number) value).doubleValue() : 0;
    }

    @SuppressWarnings("unchecked")
    private List<Integer> parseGenreIds(Object raw) {
        List<Integer> genreIds = new ArrayList<>();
        if (!(raw instanceof List<?>)) return genreIds;

        for (Object item : (List<Object>) raw) {
            if (item instanceof Number) {
                genreIds.add(((Number) item).intValue());
            } else if (item instanceof Map<?, ?>) {
                Object id = ((Map<String, Object>) item).get("id");
                if (id instanceof Number) genreIds.add(((Number) id).intValue());
            }
        }
        return genreIds;
    }

    @SuppressWarnings("unchecked")
    private List<String> parseGenreNames(Object raw) {
        List<String> genreNames = new ArrayList<>();
        if (!(raw instanceof List<?>)) return genreNames;

        for (Object item : (List<Object>) raw) {
            if (item instanceof Map<?, ?>) {
                String name = stringValue(((Map<String, Object>) item).get("name"));
                if (!name.isEmpty()) genreNames.add(name);
            }
        }
        return genreNames;
    }

    @SuppressWarnings("unchecked")
    private List<String> parseCountryCodes(Object raw) {
        List<String> codes = new ArrayList<>();
        if (!(raw instanceof List<?>)) return codes;

        for (Object item : (List<Object>) raw) {
            if (item instanceof String && !((String) item).isBlank()) {
                codes.add((String) item);
            } else if (item instanceof Map<?, ?>) {
                String code = stringValue(((Map<String, Object>) item).get("iso_3166_1"));
                if (!code.isEmpty()) codes.add(code);
            }
        }
        return codes;
    }

    @SuppressWarnings("unchecked")
    private List<SeasonVO> parseSeasons(Object raw) {
        List<SeasonVO> seasons = new ArrayList<>();
        if (!(raw instanceof List<?>)) return seasons;

        for (Object item : (List<Object>) raw) {
            if (!(item instanceof Map<?, ?>)) continue;
            Map<String, Object> map = (Map<String, Object>) item;
            SeasonVO season = new SeasonVO();
            season.setSeasonNumber(intValue(map.get("season_number")));
            season.setName(stringValue(map.get("name")));
            season.setOverview(stringValue(map.get("overview")));
            season.setPosterPath(stringValue(map.get("poster_path")));
            season.setAirDate(stringValue(map.get("air_date")));
            season.setEpisodeCount(intValue(map.get("episode_count")));
            seasons.add(season);
        }
        return seasons;
    }

    @SuppressWarnings("unchecked")
    private List<EpisodeVO> parseEpisodes(Object raw) {
        List<EpisodeVO> episodes = new ArrayList<>();
        if (!(raw instanceof List<?>)) return episodes;

        for (Object item : (List<Object>) raw) {
            if (!(item instanceof Map<?, ?>)) continue;
            Map<String, Object> map = (Map<String, Object>) item;
            EpisodeVO episode = new EpisodeVO();
            episode.setEpisodeNumber(intValue(map.get("episode_number")));
            episode.setName(stringValue(map.get("name")));
            episode.setOverview(stringValue(map.get("overview")));
            episode.setStillPath(stringValue(map.get("still_path")));
            episode.setAirDate(stringValue(map.get("air_date")));
            episode.setRuntime(intValue(map.get("runtime")));
            episode.setVoteAverage(doubleValue(map.get("vote_average")));
            episodes.add(episode);
        }
        return episodes;
    }

    @SuppressWarnings("unchecked")
    private SeasonVO parseSeasonDetail(Map<String, Object> item) {
        if (item == null || item.get("season_number") == null) return null;

        SeasonVO season = new SeasonVO();
        season.setSeasonNumber(intValue(item.get("season_number")));
        season.setName(stringValue(item.get("name")));
        season.setOverview(stringValue(item.get("overview")));
        season.setPosterPath(stringValue(item.get("poster_path")));
        season.setAirDate(stringValue(item.get("air_date")));
        season.setEpisodeCount(intValue(item.get("episode_count")));
        season.setEpisodes(parseEpisodes(item.get("episodes")));
        return season;
    }

    @SuppressWarnings("unchecked")
    private MediaContentVO parseMediaContent(Map<String, Object> item, String forcedMediaType) {
        MediaContentVO vo = new MediaContentVO();
        String mediaType = forcedMediaType != null ? forcedMediaType : stringValue(item.get("media_type"));
        vo.setTmdbId(intValue(item.get("id")));
        vo.setMediaType(mediaType);
        vo.setTitle("tv".equals(mediaType) ? stringValue(item.get("name")) : stringValue(item.get("title")));
        vo.setOriginalTitle("tv".equals(mediaType) ? stringValue(item.get("original_name")) : stringValue(item.get("original_title")));
        vo.setOverview(stringValue(item.get("overview")));
        vo.setPosterPath(stringValue(item.get("poster_path")));
        vo.setBackdropPath(stringValue(item.get("backdrop_path")));
        vo.setReleaseDate("tv".equals(mediaType) ? stringValue(item.get("first_air_date")) : stringValue(item.get("release_date")));
        vo.setVoteAverage(doubleValue(item.get("vote_average")));
        vo.setPopularity(doubleValue(item.get("popularity")));
        vo.setOriginalLanguage(stringValue(item.get("original_language")));
        vo.setGenreIds(parseGenreIds(item.get("genre_ids")));
        vo.setGenreNames(parseGenreNames(item.get("genres")));
        vo.setAnimation(vo.getGenreIds().contains(16) || vo.getGenreNames().contains("Animation"));

        if ("tv".equals(mediaType)) {
            vo.setOriginCountries(parseCountryCodes(item.get("origin_country")));
            Object runtime = item.get("episode_run_time");
            if (runtime instanceof List<?> && !((List<?>) runtime).isEmpty() && ((List<?>) runtime).get(0) instanceof Number) {
                vo.setRuntime(((Number) ((List<?>) runtime).get(0)).intValue());
            }
            vo.setSeasonCount(intValue(item.get("number_of_seasons")));
            vo.setEpisodeCount(intValue(item.get("number_of_episodes")));
            vo.setSeasons(parseSeasons(item.get("seasons")));
        } else {
            vo.setRuntime(intValue(item.get("runtime")));
            vo.setOriginCountries(parseCountryCodes(item.get("production_countries")));
        }
        return vo;
    }

    private void fillOriginCountries(MediaContentVO vo) {
        if (vo == null || !vo.getOriginCountries().isEmpty()) return;

        String path = "tv".equals(vo.getMediaType()) ? "/tv/" : "/movie/";
        String url = BASE_URL + path + vo.getTmdbId() + "?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> detail = getForMap(url);
        if (detail == null) return;

        if ("tv".equals(vo.getMediaType())) {
            vo.setOriginCountries(parseCountryCodes(detail.get("origin_country")));
        } else {
            vo.setOriginCountries(parseCountryCodes(detail.get("production_countries")));
        }
    }

    private boolean matchesCountry(MediaContentVO vo, String countryCode) {
        if (countryCode == null || countryCode.isBlank() || "ALL".equalsIgnoreCase(countryCode)) return true;
        fillOriginCountries(vo);
        return vo.getOriginCountries().contains(countryCode.toUpperCase());
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> sliceList(Map<String, Object> response, String key, int max) {
        if (response == null) return new ArrayList<>();
        List<Map<String, Object>> list = (List<Map<String, Object>>) response.get(key);
        if (list == null) return new ArrayList<>();
        return list.size() > max ? new ArrayList<>(list.subList(0, max)) : new ArrayList<>(list);
    }

    private List<Map<String, Object>> filterCrewByJobs(List<Map<String, Object>> crew) {
        String[] keyJobs = {
            "Director", "Screenplay", "Writer", "Producer",
            "Director of Photography", "Original Music Composer", "Editor", "Series Composition"
        };
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> member : crew) {
            String job = stringValue(member.get("job"));
            for (String keyJob : keyJobs) {
                if (keyJob.equals(job)) {
                    result.add(member);
                    break;
                }
            }
        }
        return result;
    }

    @SuppressWarnings("unchecked")
    private List<OttProviderVO> parseWatchProviders(Map<String, Object> response, String regionCode) {
        LinkedHashMap<Integer, OttProviderVO> providers = new LinkedHashMap<>();
        if (response == null) return new ArrayList<>();

        Map<String, Object> results = (Map<String, Object>) response.get("results");
        if (results == null) return new ArrayList<>();

        String key = (regionCode == null || regionCode.isBlank()) ? "KR" : regionCode.toUpperCase();
        Map<String, Object> region = (Map<String, Object>) results.get(key);
        if (region == null) return new ArrayList<>();

        addProviders(providers, region.get("flatrate"), "flatrate", key);
        addProviders(providers, region.get("ads"), "ads", key);
        addProviders(providers, region.get("rent"), "rent", key);
        addProviders(providers, region.get("buy"), "buy", key);
        return new ArrayList<>(providers.values());
    }

    @SuppressWarnings("unchecked")
    private void addProviders(Map<Integer, OttProviderVO> target, Object rawProviders, String providerType, String regionCode) {
        if (!(rawProviders instanceof List<?>)) return;

        for (Object item : (List<Object>) rawProviders) {
            if (!(item instanceof Map<?, ?>)) continue;
            Map<String, Object> map = (Map<String, Object>) item;
            int providerId = intValue(map.get("provider_id"));
            if (target.containsKey(providerId)) continue;

            OttProviderVO provider = new OttProviderVO();
            provider.setProviderId(providerId);
            provider.setProviderName(stringValue(map.get("provider_name")));
            provider.setLogoPath(stringValue(map.get("logo_path")));
            provider.setDisplayPriority(intValue(map.get("display_priority")));
            provider.setProviderType(providerType);
            provider.setRegionCode(regionCode);
            target.put(providerId, provider);
        }
    }

    @Override
    public List<MovieVO> getPopularMovies(int page) {
        String url = BASE_URL + "/movie/popular?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page + "&region=KR";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getPopularMovies(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getPopularMovies(page);
        String country = normalizedCountry(countryCode);
        String url = BASE_URL + "/discover/movie?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&page=" + page
                + "&sort_by=popularity.desc"
                + "&region=" + country
                + "&with_origin_country=" + country
                + "&include_adult=false";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getNowPlayingMovies(int page) {
        String url = BASE_URL + "/movie/now_playing?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page + "&region=KR";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getNowPlayingMovies(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getNowPlayingMovies(page);
        String country = normalizedCountry(countryCode);
        LocalDate today = LocalDate.now();
        LocalDate from = today.minusDays(45);
        String url = BASE_URL + "/discover/movie?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&page=" + page
                + "&sort_by=popularity.desc"
                + "&region=" + country
                + "&with_origin_country=" + country
                + "&release_date.gte=" + from
                + "&release_date.lte=" + today
                + "&include_adult=false";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getTopRatedMovies(int page) {
        String url = BASE_URL + "/movie/top_rated?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page;
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getTopRatedMovies(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getTopRatedMovies(page);
        String country = normalizedCountry(countryCode);
        String url = BASE_URL + "/discover/movie?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&page=" + page
                + "&sort_by=vote_average.desc"
                + "&vote_count.gte=200"
                + "&region=" + country
                + "&with_origin_country=" + country
                + "&include_adult=false";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MediaContentVO> getPopularTvShows(int page) {
        String url = BASE_URL + "/tv/popular?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page;
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MediaContentVO> getPopularTvShows(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getPopularTvShows(page);
        String country = normalizedCountry(countryCode);
        String url = BASE_URL + "/discover/tv?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&page=" + page
                + "&sort_by=popularity.desc"
                + "&with_origin_country=" + country
                + "&include_adult=false";
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MediaContentVO> getTopRatedTvShows(int page) {
        String url = BASE_URL + "/tv/top_rated?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page;
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MediaContentVO> getTopRatedTvShows(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getTopRatedTvShows(page);
        String country = normalizedCountry(countryCode);
        String url = BASE_URL + "/discover/tv?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&page=" + page
                + "&sort_by=vote_average.desc"
                + "&vote_count.gte=50"
                + "&with_origin_country=" + country
                + "&include_adult=false";
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MediaContentVO> getOnTheAirTvShows(int page) {
        String url = BASE_URL + "/tv/on_the_air?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page;
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MediaContentVO> getOnTheAirTvShows(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getOnTheAirTvShows(page);
        String country = normalizedCountry(countryCode);
        int safePage = Math.max(page, 1);
        int requiredItems = safePage * TMDB_PAGE_SIZE + 1;
        int rawTotalPages = 0;
        List<MediaContentVO> filtered = new ArrayList<>();

        for (int rawPage = 1; rawPage == 1 || (rawPage <= rawTotalPages && filtered.size() < requiredItems); rawPage++) {
            Map<String, Object> response = getForMap(buildOnTheAirTvUrl(rawPage));
            if (response == null) {
                if (rawPage == 1) return new ArrayList<>();
                break;
            }

            rawTotalPages = Math.max(rawTotalPages, intValue(response.get("total_pages")));
            for (MediaContentVO content : parseMediaList(response, "tv")) {
                if (matchesCountry(content, country)) {
                    filtered.add(content);
                }
            }
        }

        int fromIndex = (safePage - 1) * TMDB_PAGE_SIZE;
        if (fromIndex >= filtered.size()) return new ArrayList<>();

        int toIndex = Math.min(fromIndex + TMDB_PAGE_SIZE, filtered.size());
        return new ArrayList<>(filtered.subList(fromIndex, toIndex));
    }

    @Override
    public List<MediaContentVO> getAnimationMovies(int page) {
        String url = BASE_URL + "/discover/movie?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&with_genres=16"
                + "&page=" + page
                + "&region=KR"
                + "&sort_by=popularity.desc";
        return parseMediaList(getForMap(url), "movie");
    }

    @Override
    public List<MediaContentVO> getAnimationMovies(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getAnimationMovies(page);
        String country = normalizedCountry(countryCode);
        String url = BASE_URL + "/discover/movie?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&with_genres=16"
                + "&page=" + page
                + "&region=" + country
                + "&with_origin_country=" + country
                + "&sort_by=popularity.desc"
                + "&include_adult=false";
        return parseMediaList(getForMap(url), "movie");
    }

    @Override
    public List<MediaContentVO> getAnimationTvShows(int page) {
        String url = BASE_URL + "/discover/tv?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&with_genres=16"
                + "&page=" + page
                + "&sort_by=popularity.desc";
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MediaContentVO> getAnimationTvShows(int page, String countryCode) {
        if (isAllCountry(countryCode)) return getAnimationTvShows(page);
        String country = normalizedCountry(countryCode);
        String url = BASE_URL + "/discover/tv?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&with_genres=16"
                + "&page=" + page
                + "&with_origin_country=" + country
                + "&sort_by=popularity.desc"
                + "&include_adult=false";
        return parseMediaList(getForMap(url), "tv");
    }

    @Override
    public List<MovieVO> searchMovies(String query, int page) {
        String url = BASE_URL + "/search/movie?api_key=" + resolveApiKey() + "&language=" + LANG + "&query=" + encoded(query) + "&page=" + page;
        return parseMovieList(getForMap(url));
    }

    @Override
    @SuppressWarnings("unchecked")
    public MediaSearchResultVO searchContents(String query, int page, String mediaType, String countryCode) {
        if ("tv".equalsIgnoreCase(mediaType)) {
            return searchTvContents(query, page, countryCode);
        }

        MediaSearchResultVO result = new MediaSearchResultVO();
        int safePage = Math.max(page, 1);
        result.setPage(safePage);

        if (query == null || query.trim().isEmpty()) return result;

        int requiredMatches = safePage * TMDB_PAGE_SIZE + 1;
        int rawTotalPages = 0;
        int fetchedRawPages = 0;
        List<MediaContentVO> filtered = new ArrayList<>();

        for (int rawPage = 1; rawPage == 1 || (rawPage <= rawTotalPages && filtered.size() < requiredMatches); rawPage++) {
            Map<String, Object> response = getForMap(buildMultiSearchUrl(query, rawPage));
            if (response == null) {
                if (rawPage == 1) return result;
                break;
            }

            fetchedRawPages = rawPage;
            rawTotalPages = Math.max(rawTotalPages, intValue(response.get("total_pages")));
            List<Map<String, Object>> items = (List<Map<String, Object>>) response.get("results");
            if (items == null) continue;

            for (Map<String, Object> item : items) {
                String itemType = stringValue(item.get("media_type"));
                if (!"movie".equals(itemType) && !"tv".equals(itemType)) continue;

                MediaContentVO content = parseMediaContent(item, itemType);
                if (!matchesRequestedMediaType(content, mediaType)) continue;
                if (!matchesCountry(content, countryCode)) continue;
                filtered.add(content);
            }
        }

        int fromIndex = (safePage - 1) * TMDB_PAGE_SIZE;
        if (fromIndex >= filtered.size()) {
            result.setContents(new ArrayList<>());
            result.setTotalResults(filtered.size());
            result.setTotalPages(Math.max(1, safePage - 1));
            result.setHasNextPage(false);
            return result;
        }

        int toIndex = Math.min(fromIndex + TMDB_PAGE_SIZE, filtered.size());
        result.setContents(new ArrayList<>(filtered.subList(fromIndex, toIndex)));
        result.setTotalResults(filtered.size());

        boolean moreMatchesAlreadyFetched = filtered.size() > toIndex;
        boolean moreRawPagesRemain = fetchedRawPages < rawTotalPages;
        result.setHasNextPage(moreMatchesAlreadyFetched || moreRawPagesRemain);
        result.setTotalPages(result.isHasNextPage() ? safePage + 1 : safePage);
        return result;
    }

    @SuppressWarnings("unchecked")
    private MediaSearchResultVO searchTvContents(String query, int page, String countryCode) {
        MediaSearchResultVO result = new MediaSearchResultVO();
        int safePage = Math.max(page, 1);
        result.setPage(safePage);

        if (query == null || query.trim().isEmpty()) return result;

        int requiredMatches = safePage * TMDB_PAGE_SIZE + 1;
        int rawTotalPages = 0;
        int fetchedRawPages = 0;
        List<MediaContentVO> filtered = new ArrayList<>();

        for (int rawPage = 1; rawPage == 1 || (rawPage <= rawTotalPages && filtered.size() < requiredMatches); rawPage++) {
            Map<String, Object> response = getForMap(buildTvSearchUrl(query, rawPage));
            if (response == null) {
                if (rawPage == 1) return result;
                break;
            }

            fetchedRawPages = rawPage;
            rawTotalPages = Math.max(rawTotalPages, intValue(response.get("total_pages")));
            List<Map<String, Object>> items = (List<Map<String, Object>>) response.get("results");
            if (items == null) continue;

            for (Map<String, Object> item : items) {
                MediaContentVO content = parseMediaContent(item, "tv");
                if (!matchesCountry(content, countryCode)) continue;
                filtered.add(content);
            }
        }

        int fromIndex = (safePage - 1) * TMDB_PAGE_SIZE;
        if (fromIndex >= filtered.size()) {
            result.setContents(new ArrayList<>());
            result.setTotalResults(filtered.size());
            result.setTotalPages(Math.max(1, safePage - 1));
            result.setHasNextPage(false);
            return result;
        }

        int toIndex = Math.min(fromIndex + TMDB_PAGE_SIZE, filtered.size());
        result.setContents(new ArrayList<>(filtered.subList(fromIndex, toIndex)));
        result.setTotalResults(filtered.size());

        boolean moreMatchesAlreadyFetched = filtered.size() > toIndex;
        boolean moreRawPagesRemain = fetchedRawPages < rawTotalPages;
        result.setHasNextPage(moreMatchesAlreadyFetched || moreRawPagesRemain);
        result.setTotalPages(result.isHasNextPage() ? safePage + 1 : safePage);
        return result;
    }

    @Override
    public MovieVO getMovieDetail(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> item = getForMap(url);
        if (item == null || item.get("id") == null) return null;

        MovieVO vo = new MovieVO();
        vo.setTmdbId(((Number) item.get("id")).intValue());
        vo.setTitle(item.get("title") != null ? (String) item.get("title") : "");
        vo.setOriginalTitle(item.get("original_title") != null ? (String) item.get("original_title") : "");
        vo.setOverview(item.get("overview") != null ? (String) item.get("overview") : "");
        vo.setPosterPath(item.get("poster_path") != null ? (String) item.get("poster_path") : "");
        vo.setBackdropPath(item.get("backdrop_path") != null ? (String) item.get("backdrop_path") : "");
        vo.setReleaseDate(item.get("release_date") != null ? (String) item.get("release_date") : "");
        vo.setRuntime(item.get("runtime") != null ? ((Number) item.get("runtime")).intValue() : 0);
        vo.setVoteAverage(item.get("vote_average") != null ? ((Number) item.get("vote_average")).doubleValue() : 0);
        vo.setPopularity(item.get("popularity") != null ? ((Number) item.get("popularity")).doubleValue() : 0);
        return vo;
    }

    @Override
    public MediaContentVO getTvDetail(int tmdbId) {
        String url = BASE_URL + "/tv/" + tmdbId + "?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> item = getForMap(url);
        if (item == null || item.get("id") == null) return null;
        return parseMediaContent(item, "tv");
    }

    @Override
    public SeasonVO getTvSeasonDetail(int tmdbId, int seasonNo) {
        String url = BASE_URL + "/tv/" + tmdbId + "/season/" + seasonNo + "?api_key=" + resolveApiKey() + "&language=" + LANG;
        return parseSeasonDetail(getForMap(url));
    }

    @Override
    public List<MovieVO> getMoviesByGenre(int genreId, int page) {
        String url = BASE_URL + "/discover/movie?api_key=" + resolveApiKey()
                + "&language=" + LANG
                + "&with_genres=" + genreId
                + "&page=" + page
                + "&region=KR"
                + "&sort_by=popularity.desc";
        return parseMovieList(getForMap(url));
    }

    @Override
    public MediaSearchResultVO getContentsByGenre(int genreId, int page) {
        int safePage = Math.max(page, 1);
        int requiredItems = safePage * COMBINED_PAGE_SIZE + 1;
        int sourcePagesToFetch = pagesNeededFor(requiredItems);

        MediaSearchResultVO result = new MediaSearchResultVO();
        result.setPage(safePage);

        List<MediaContentVO> merged = new ArrayList<>();
        int movieTotalPages = 0;
        int tvTotalPages = 0;

        for (int sourcePage = 1; sourcePage <= sourcePagesToFetch; sourcePage++) {
            if (sourcePage == 1 || sourcePage <= movieTotalPages) {
                Map<String, Object> movieResponse = getForMap(buildGenreDiscoverUrl("movie", genreId, sourcePage));
                if (movieResponse != null) {
                    movieTotalPages = Math.max(movieTotalPages, intValue(movieResponse.get("total_pages")));
                    merged.addAll(parseMediaList(movieResponse, "movie"));
                }
            }

            if (sourcePage == 1 || sourcePage <= tvTotalPages) {
                Map<String, Object> tvResponse = getForMap(buildGenreDiscoverUrl("tv", genreId, sourcePage));
                if (tvResponse != null) {
                    tvTotalPages = Math.max(tvTotalPages, intValue(tvResponse.get("total_pages")));
                    merged.addAll(parseMediaList(tvResponse, "tv"));
                }
            }
        }

        merged.sort((a, b) -> Double.compare(b.getPopularity(), a.getPopularity()));

        int fromIndex = (safePage - 1) * COMBINED_PAGE_SIZE;
        if (fromIndex >= merged.size()) {
            result.setContents(new ArrayList<>());
            result.setTotalResults(merged.size());
            result.setTotalPages(Math.max(1, safePage - 1));
            result.setHasNextPage(false);
            return result;
        }

        int toIndex = Math.min(fromIndex + COMBINED_PAGE_SIZE, merged.size());
        result.setContents(new ArrayList<>(merged.subList(fromIndex, toIndex)));
        result.setTotalResults(merged.size());

        boolean moreItemsAlreadyFetched = merged.size() > toIndex;
        boolean moreSourcePagesRemain = sourcePagesToFetch < movieTotalPages || sourcePagesToFetch < tvTotalPages;
        result.setHasNextPage(moreItemsAlreadyFetched || moreSourcePagesRemain);
        result.setTotalPages(result.isHasNextPage() ? safePage + 1 : safePage);
        return result;
    }

    @Override
    public List<Map<String, Object>> getCastList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        return sliceList(getForMap(url), "cast", 16);
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCrewList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> res = getForMap(url);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> crew = (List<Map<String, Object>>) res.get("crew");
        if (crew == null) return new ArrayList<>();
        return filterCrewByJobs(crew);
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getVideoList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/videos?api_key=" + resolveApiKey() + "&language=" + LANG;
        List<Map<String, Object>> list = filterPlayableYoutubeVideos(filterYoutube(getForMap(url)), true);

        if (list.isEmpty()) {
            url = BASE_URL + "/movie/" + tmdbId + "/videos?api_key=" + resolveApiKey() + "&language=en-US";
            list = filterPlayableYoutubeVideos(filterYoutube(getForMap(url)), true);
        }
        return list;
    }

    @Override
    public List<Map<String, Object>> getTvCastList(int tmdbId) {
        String url = BASE_URL + "/tv/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        return sliceList(getForMap(url), "cast", 16);
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getTvCrewList(int tmdbId) {
        String url = BASE_URL + "/tv/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> res = getForMap(url);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> crew = (List<Map<String, Object>>) res.get("crew");
        if (crew == null) return new ArrayList<>();
        return filterCrewByJobs(crew);
    }

    @Override
    public List<Map<String, Object>> getTvVideoList(int tmdbId) {
        List<Map<String, Object>> cached = getCachedVideoList("tv", tmdbId, null, TMDB_VIDEO_CACHE_SOURCE);
        if (!cached.isEmpty()) return cached;

        String url = BASE_URL + "/tv/" + tmdbId + "/videos?api_key=" + resolveApiKey() + "&language=" + LANG;
        List<Map<String, Object>> list = filterPlayableYoutubeVideos(filterYoutube(getForMap(url)), true);
        if (!list.isEmpty()) {
            if (!isYoutubeQuotaBlocked()) {
                saveVideoCache("tv", tmdbId, null, TMDB_VIDEO_CACHE_SOURCE, list);
            }
            return list;
        }

        url = BASE_URL + "/tv/" + tmdbId + "/videos?api_key=" + resolveApiKey() + "&language=en-US";
        list = filterPlayableYoutubeVideos(filterYoutube(getForMap(url)), true);
        if (!list.isEmpty()) {
            if (!isYoutubeQuotaBlocked()) {
                saveVideoCache("tv", tmdbId, null, TMDB_VIDEO_CACHE_SOURCE, list);
            }
            return list;
        }

        MediaContentVO tv = getTvDetail(tmdbId);
        List<String> titleCandidates = youtubeTitleCandidates(tv);
        if (titleCandidates.isEmpty()) return list;
        if (isYoutubeQuotaBlocked()) return new ArrayList<>();

        cached = rankYoutubeFallbackVideos(getCachedVideoList("tv", tmdbId, null, YOUTUBE_VIDEO_CACHE_SOURCE), titleCandidates, null);
        if (!cached.isEmpty()) return cached;

        List<String> queries = buildSeriesYoutubeQueries(titleCandidates);
        list = searchYoutubeFallbackCandidates(titleCandidates, null, queries.toArray(new String[0]));
        if (!list.isEmpty()) {
            saveVideoCache("tv", tmdbId, null, YOUTUBE_VIDEO_CACHE_SOURCE, list);
        }
        return list;
    }

    @Override
    public List<Map<String, Object>> getTvSeasonVideoList(int tmdbId, int seasonNo) {
        List<Map<String, Object>> cached = getCachedVideoList("tv", tmdbId, seasonNo, TMDB_VIDEO_CACHE_SOURCE);
        if (!cached.isEmpty()) return cached;

        String url = BASE_URL + "/tv/" + tmdbId + "/season/" + seasonNo + "/videos?api_key=" + resolveApiKey() + "&language=" + LANG;
        List<Map<String, Object>> list = filterPlayableYoutubeVideos(filterYoutube(getForMap(url)), true);
        if (!list.isEmpty()) {
            if (!isYoutubeQuotaBlocked()) {
                saveVideoCache("tv", tmdbId, seasonNo, TMDB_VIDEO_CACHE_SOURCE, list);
            }
            return list;
        }

        url = BASE_URL + "/tv/" + tmdbId + "/season/" + seasonNo + "/videos?api_key=" + resolveApiKey() + "&language=en-US";
        list = filterPlayableYoutubeVideos(filterYoutube(getForMap(url)), true);
        if (!list.isEmpty()) {
            if (!isYoutubeQuotaBlocked()) {
                saveVideoCache("tv", tmdbId, seasonNo, TMDB_VIDEO_CACHE_SOURCE, list);
            }
            return list;
        }

        MediaContentVO tv = getTvDetail(tmdbId);
        List<String> titleCandidates = youtubeTitleCandidates(tv);
        if (titleCandidates.isEmpty()) return list;
        if (isYoutubeQuotaBlocked()) return new ArrayList<>();

        cached = rankYoutubeFallbackVideos(getCachedVideoList("tv", tmdbId, seasonNo, YOUTUBE_VIDEO_CACHE_SOURCE), titleCandidates, seasonNo);
        if (!cached.isEmpty()) return cached;

        SeasonVO season = getTvSeasonDetail(tmdbId, seasonNo);
        List<String> queries = buildSeasonYoutubeQueries(titleCandidates, seasonNo, season);
        list = searchYoutubeFallbackCandidates(titleCandidates, seasonNo, queries.toArray(new String[0]));
        if (!list.isEmpty()) {
            saveVideoCache("tv", tmdbId, seasonNo, YOUTUBE_VIDEO_CACHE_SOURCE, list);
        }
        return list;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> filterYoutube(Map<String, Object> res) {
        List<Map<String, Object>> out = new ArrayList<>();
        if (res == null) return out;
        List<Map<String, Object>> results = (List<Map<String, Object>>) res.get("results");
        if (results == null) return out;
        for (Map<String, Object> video : results) {
            if ("YouTube".equals(video.get("site"))) out.add(video);
        }
        return out;
    }

    @Override
    public Map<String, Object> getMovieCredits(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        return getForMap(url);
    }

    @Override
    public List<Map<String, Object>> getMovieVideos(int tmdbId) {
        return getVideoList(tmdbId);
    }

    @Override
    public List<OttProviderVO> getMovieWatchProviders(int tmdbId, String regionCode) {
        String url = BASE_URL + "/movie/" + tmdbId + "/watch/providers?api_key=" + resolveApiKey();
        return parseWatchProviders(getForMap(url), regionCode);
    }

    @Override
    public List<OttProviderVO> getTvWatchProviders(int tmdbId, String regionCode) {
        String url = BASE_URL + "/tv/" + tmdbId + "/watch/providers?api_key=" + resolveApiKey();
        return parseWatchProviders(getForMap(url), regionCode);
    }

    @Override
    public Map<String, Object> getPersonDetail(int personId) {
        String url = BASE_URL + "/person/" + personId + "?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> res = getForMap(url);
        return res != null ? res : Map.of();
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getPersonMovies(int personId) {
        String url = BASE_URL + "/person/" + personId + "/movie_credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> res = getForMap(url);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> cast = (List<Map<String, Object>>) res.get("cast");
        if (cast == null) return new ArrayList<>();
        cast.sort((a, b) -> {
            String da = (String) a.getOrDefault("release_date", "");
            String db = (String) b.getOrDefault("release_date", "");
            return db.compareTo(da);
        });
        return cast;
    }

    @Override
    public List<MovieVO> getUpcomingMovies(int page) {
        String url = BASE_URL + "/movie/upcoming?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page + "&region=KR";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getTrendingMovies(String timeWindow) {
        String url = BASE_URL + "/trending/movie/" + timeWindow + "?api_key=" + resolveApiKey() + "&language=" + LANG;
        return parseMovieList(getForMap(url));
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMovieKeywords(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/keywords?api_key=" + resolveApiKey();
        Map<String, Object> res = getForMap(url);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> keywords = (List<Map<String, Object>>) res.get("keywords");
        return keywords != null ? keywords : new ArrayList<>();
    }

    @Override
    public List<MovieVO> getSimilarMovies(int tmdbId, int page) {
        String url = BASE_URL + "/movie/" + tmdbId + "/similar?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page;
        return parseMovieList(getForMap(url));
    }
}
