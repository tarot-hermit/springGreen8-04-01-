package com.spring.springGreen8.service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.spring.springGreen8.vo.MovieVO;

@Service
public class TmdbServiceImpl implements TmdbService {

    @Autowired
    private RestTemplate restTemplate;

    // API 키
    private static final String API_KEY = "66da9cfe880193a0b0b756b8fb46a5a3";
    // 기본 URL
    private static final String BASE_URL = "https://api.themoviedb.org/3";
    // 한국어 설정
    private static final String LANG = "ko-KR";

    // JSON → MovieVO 변환
    @SuppressWarnings("unchecked")
    private List<MovieVO> parseMovieList(Map<String, Object> response) {
        List<MovieVO> list = new ArrayList<>();
        List<Map<String, Object>> results =
            (List<Map<String, Object>>) response.get("results");
        if (results == null) return list;

        for (Map<String, Object> item : results) {
            MovieVO vo = new MovieVO();
            vo.setTmdbId(item.get("id") != null ?
                ((Number) item.get("id")).intValue() : 0);
            vo.setTitle(item.get("title") != null ?
                (String) item.get("title") : "");
            vo.setOriginalTitle(item.get("original_title") != null ?
                (String) item.get("original_title") : "");
            vo.setOverview(item.get("overview") != null ?
                (String) item.get("overview") : "");
            vo.setPosterPath(item.get("poster_path") != null ?
                (String) item.get("poster_path") : "");
            vo.setBackdropPath(item.get("backdrop_path") != null ?
                (String) item.get("backdrop_path") : "");
            vo.setReleaseDate(item.get("release_date") != null ?
                (String) item.get("release_date") : "");
            vo.setVoteAverage(item.get("vote_average") != null ?
                ((Number) item.get("vote_average")).doubleValue() : 0);
            vo.setPopularity(item.get("popularity") != null ?
                ((Number) item.get("popularity")).doubleValue() : 0);
            list.add(vo);
        }
        return list;
    }

    // 인기 영화
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getPopularMovies(int page) {
        String url = BASE_URL + "/movie/popular?api_key=" + API_KEY
                   + "&language=" + LANG + "&page=" + page
                   + "&region=KR";
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

    // 현재 상영중
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getNowPlayingMovies(int page) {
        String url = BASE_URL + "/movie/now_playing?api_key=" + API_KEY
                   + "&language=" + LANG + "&page=" + page
                   + "&region=KR";
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

    // 최고 평점
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getTopRatedMovies(int page) {
        String url = BASE_URL + "/movie/top_rated?api_key=" + API_KEY
                   + "&language=" + LANG + "&page=" + page;
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

    // 영화 검색
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> searchMovies(String query, int page) {
        String url = BASE_URL + "/search/movie?api_key=" + API_KEY
                   + "&language=" + LANG + "&query="
                   + query + "&page=" + page;
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

    // 영화 상세
    @Override
    @SuppressWarnings("unchecked")
    public MovieVO getMovieDetail(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "?api_key=" + API_KEY
                   + "&language=" + LANG;
        Map<String, Object> item =
            restTemplate.getForObject(url, Map.class);
        if (item == null) return null;

        MovieVO vo = new MovieVO();
        vo.setTmdbId(((Number) item.get("id")).intValue());
        vo.setTitle(item.get("title") != null ?
            (String) item.get("title") : "");
        vo.setOriginalTitle(item.get("original_title") != null ?
            (String) item.get("original_title") : "");
        vo.setOverview(item.get("overview") != null ?
            (String) item.get("overview") : "");
        vo.setPosterPath(item.get("poster_path") != null ?
            (String) item.get("poster_path") : "");
        vo.setBackdropPath(item.get("backdrop_path") != null ?
            (String) item.get("backdrop_path") : "");
        vo.setReleaseDate(item.get("release_date") != null ?
            (String) item.get("release_date") : "");
        vo.setRuntime(item.get("runtime") != null ?
            ((Number) item.get("runtime")).intValue() : 0);
        vo.setVoteAverage(item.get("vote_average") != null ?
            ((Number) item.get("vote_average")).doubleValue() : 0);
        vo.setPopularity(item.get("popularity") != null ?
            ((Number) item.get("popularity")).doubleValue() : 0);
        return vo;
    }
    
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getMoviesByGenre(int genreId , int page) {
    	String url = BASE_URL + "/discover/movie?api_key=" + API_KEY
    			+ "&language=" + LANG
    			+ "&with_genres=" + genreId
    			+ "&page=" + page
    			+ "&region=KR" 
    			+ "&sort_by=popularity.desc";
    	Map<String, Object> response = 
    			restTemplate.getForObject(url, Map.class);
    	return parseMovieList(response);
    }
    
 // 출연진
    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCastList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + API_KEY
                   + "&language=" + LANG;
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> cast =
            (List<Map<String, Object>>) res.get("cast");
        if (cast == null) return new ArrayList<>();
        // 상위 16명만
        return cast.size() > 16 ? cast.subList(0, 16) : cast;
    }

    // 스태프 (감독·각본·촬영·음악 등 주요 직책만)
    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getCrewList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + API_KEY
                   + "&language=" + LANG;
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> crew =
            (List<Map<String, Object>>) res.get("crew");
        if (crew == null) return new ArrayList<>();

        String[] keyJobs = {
            "Director", "Screenplay", "Writer", "Producer",
            "Director of Photography", "Original Music Composer", "Editor"
        };
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> m : crew) {
            String job = (String) m.get("job");
            if (job == null) continue;
            for (String k : keyJobs) {
                if (k.equals(job)) { result.add(m); break; }
            }
        }
        return result;
    }

    // 예고편 (YouTube만, 한국어 없으면 영어 fallback)
    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getVideoList(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/videos?api_key=" + API_KEY
                   + "&language=" + LANG;
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        List<Map<String, Object>> list = filterYoutube(res);

        if (list.isEmpty()) {  // 한국어 없으면 영어로 재시도
            url = BASE_URL + "/movie/" + tmdbId + "/videos?api_key=" + API_KEY
                + "&language=en-US";
            res = restTemplate.getForObject(url, Map.class);
            list = filterYoutube(res);
        }
        return list;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> filterYoutube(Map<String, Object> res) {
        List<Map<String, Object>> out = new ArrayList<>();
        if (res == null) return out;
        List<Map<String, Object>> results =
            (List<Map<String, Object>>) res.get("results");
        if (results == null) return out;
        for (Map<String, Object> v : results) {
            if ("YouTube".equals(v.get("site"))) out.add(v);
        }
        return out;
    }
    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> getMovieCredits(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/credits?api_key=" + API_KEY
                   + "&language=" + LANG;
        return restTemplate.getForObject(url, Map.class);
    }

    @Override
    public List<Map<String, Object>> getMovieVideos(int tmdbId) {
        return getVideoList(tmdbId);
    }
 // 배우 기본 정보 (이름, 사진, 약력 등)
    @Override
    @SuppressWarnings("unchecked")
    public Map<String, Object> getPersonDetail(int personId) {
        String url = BASE_URL + "/person/" + personId + "?api_key=" + API_KEY
                   + "&language=" + LANG;
        return restTemplate.getForObject(url, Map.class);
    }

    // 배우 출연 영화 목록
    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getPersonMovies(int personId) {
        String url = BASE_URL + "/person/" + personId + "/movie_credits?api_key=" + API_KEY
                   + "&language=" + LANG;
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> cast =
            (List<Map<String, Object>>) res.get("cast");
        if (cast == null) return new ArrayList<>();
        // 최신순 정렬 (release_date 내림차순)
        cast.sort((a, b) -> {
            String da = (String) a.getOrDefault("release_date", "");
            String db = (String) b.getOrDefault("release_date", "");
            return db.compareTo(da);
        });
        return cast;
    }
    
    // 개봉 예정
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getUpcomingMovies(int page) {
        String url = BASE_URL + "/movie/upcoming?api_key=" + API_KEY
                   + "&language=" + LANG + "&page=" + page
                   + "&region=KR";
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

    // 트렌딩 (timeWindow: "day" | "week")
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getTrendingMovies(String timeWindow) {
        String url = BASE_URL + "/trending/movie/" + timeWindow
                   + "?api_key=" + API_KEY + "&language=" + LANG;
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

    // 영화 키워드 태그
    @Override
    @SuppressWarnings("unchecked")
    public List<Map<String, Object>> getMovieKeywords(int tmdbId) {
        String url = BASE_URL + "/movie/" + tmdbId + "/keywords?api_key=" + API_KEY;
        Map<String, Object> res = restTemplate.getForObject(url, Map.class);
        if (res == null) return new ArrayList<>();
        List<Map<String, Object>> keywords =
            (List<Map<String, Object>>) res.get("keywords");
        return keywords != null ? keywords : new ArrayList<>();
    }

    // 비슷한 영화
    @Override
    @SuppressWarnings("unchecked")
    public List<MovieVO> getSimilarMovies(int tmdbId, int page) {
        String url = BASE_URL + "/movie/" + tmdbId + "/similar?api_key=" + API_KEY
                   + "&language=" + LANG + "&page=" + page;
        Map<String, Object> response =
            restTemplate.getForObject(url, Map.class);
        return parseMovieList(response);
    }

}