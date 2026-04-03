package com.spring.springGreen8.service;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import com.spring.springGreen8.vo.MovieVO;

@Service
public class TmdbServiceImpl implements TmdbService {

    private static final Logger log = LoggerFactory.getLogger(TmdbServiceImpl.class);
    private static final String BASE_URL = "https://api.themoviedb.org/3";
    private static final String LANG = "ko-KR";

    @Autowired
    private RestTemplate restTemplate;

    @Value("${tmdb.api.key:}")
    private String apiKey;

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
        try {
            return restTemplate.getForObject(url, Map.class);
        } catch (RestClientException e) {
            log.warn("TMDB request failed: {}", url, e);
            return null;
        }
    }

    private String encoded(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    @Override
    public List<MovieVO> getPopularMovies(int page) {
        String url = BASE_URL + "/movie/popular?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page + "&region=KR";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getNowPlayingMovies(int page) {
        String url = BASE_URL + "/movie/now_playing?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page + "&region=KR";
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> getTopRatedMovies(int page) {
        String url = BASE_URL + "/movie/top_rated?api_key=" + resolveApiKey() + "&language=" + LANG + "&page=" + page;
        return parseMovieList(getForMap(url));
    }

    @Override
    public List<MovieVO> searchMovies(String query, int page) {
        String url = BASE_URL + "/search/movie?api_key=" + resolveApiKey() + "&language=" + LANG + "&query=" + encoded(query) + "&page=" + page;
        return parseMovieList(getForMap(url));
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
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCastList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> res = getForMap(url);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> cast = (List<Map<String, Object>>) res.get("cast");
        if (cast == null) return new ArrayList<>();
        return cast.size() > 16 ? cast.subList(0, 16) : cast;
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCrewList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + resolveApiKey() + "&language=" + LANG;
        Map<String, Object> res = getForMap(url);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> crew = (List<Map<String, Object>>) res.get("crew");
        if (crew == null) return new ArrayList<>();

        String[] keyJobs = {
            "Director", "Screenplay", "Writer", "Producer",
            "Director of Photography", "Original Music Composer", "Editor"
        };
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> member : crew) {
            String job = (String) member.get("job");
            if (job == null) continue;
            for (String keyJob : keyJobs) {
                if (keyJob.equals(job)) {
                    result.add(member);
                    break;
                }
            }
        }
        return result;
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getVideoList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/videos?api_key=" + resolveApiKey() + "&language=" + LANG;
        List<Map<String, Object>> list = filterYoutube(getForMap(url));

        if (list.isEmpty()) {
            url = BASE_URL + "/movie/" + tmdbId + "/videos?api_key=" + resolveApiKey() + "&language=en-US";
            list = filterYoutube(getForMap(url));
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
