package com.spring.springGreen8.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.dao.SearchHistoryDAO;
import com.spring.springGreen8.service.ReviewService;
import com.spring.springGreen8.service.TmdbService;
import com.spring.springGreen8.service.WatchedService;
import com.spring.springGreen8.service.WatchlistService;
import com.spring.springGreen8.vo.MediaContentVO;
import com.spring.springGreen8.vo.MediaSearchResultVO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.SearchHistoryVO;
import com.spring.springGreen8.vo.SeasonVO;
import com.spring.springGreen8.vo.UserVO;
import com.spring.springGreen8.vo.WatchlistVO;

/**
 * 콘텐츠 탐색과 상세 화면을 담당하는 컨트롤러.
 * 영화/드라마/애니메이션 목록, 검색, 상세, 예고편, 찜/봤어요 진입 요청을 처리한다.
 */
@Controller
@RequestMapping("/movie")
public class MovieController {

    @Autowired private TmdbService tmdbService;
    @Autowired private MovieDAO movieDAO;
    @Autowired private WatchlistService watchlistService;
    @Autowired private ReviewService reviewService;
    @Autowired private SearchHistoryDAO searchHistoryDAO;
    @Autowired private WatchedService watchedService;

    @RequestMapping("/list")
    public String list(@RequestParam(defaultValue = "1") int page,
                       @RequestParam(defaultValue = "ALL") String country,
                       @RequestParam(defaultValue = "popular") String tab,
                       Model model) {
        model.addAttribute("popularList", tmdbService.getPopularMovies(page, country));
        model.addAttribute("nowPlayingList", tmdbService.getNowPlayingMovies(page, country));
        model.addAttribute("topRatedList", tmdbService.getTopRatedMovies(page, country));
        model.addAttribute("page", page);
        model.addAttribute("country", country);
        model.addAttribute("activeTab", resolveMovieTab(tab));
        return "movie/list";
    }

    private String resolveMovieTab(String tab) {
        if ("nowplaying".equalsIgnoreCase(tab)) return "nowplaying";
        if ("toprated".equalsIgnoreCase(tab)) return "toprated";
        return "popular";
    }

    @RequestMapping("/tv")
    public String tvList(@RequestParam(defaultValue = "1") int page,
                         @RequestParam(defaultValue = "ALL") String country,
                         @RequestParam(defaultValue = "popular") String tab,
                         Model model) {
        model.addAttribute("popularList", tmdbService.getPopularTvShows(page, country));
        model.addAttribute("onTheAirList", tmdbService.getOnTheAirTvShows(page, country));
        model.addAttribute("topRatedList", tmdbService.getTopRatedTvShows(page, country));
        model.addAttribute("page", page);
        model.addAttribute("country", country);
        model.addAttribute("activeTab", resolveTvTab(tab));
        return "movie/tvList";
    }

    private String resolveTvTab(String tab) {
        if ("onair".equalsIgnoreCase(tab)) return "onair";
        if ("toprated".equalsIgnoreCase(tab)) return "toprated";
        return "popular";
    }

    @RequestMapping("/animation")
    public String animationList(@RequestParam(defaultValue = "1") int page,
                                @RequestParam(defaultValue = "ALL") String country,
                                @RequestParam(defaultValue = "movie") String tab,
                                Model model) {
        model.addAttribute("movieList", tmdbService.getAnimationMovies(page, country));
        model.addAttribute("tvList", tmdbService.getAnimationTvShows(page, country));
        model.addAttribute("page", page);
        model.addAttribute("country", country);
        model.addAttribute("activeTab", "tv".equalsIgnoreCase(tab) ? "tv" : "movie");
        return "movie/animationList";
    }

    @RequestMapping("/all")
    public String allList(@RequestParam(defaultValue = "1") int page,
                          @RequestParam(defaultValue = "ALL") String country,
                          Model model) {
        model.addAttribute("movieList", tmdbService.getPopularMovies(page, country));
        model.addAttribute("tvList", tmdbService.getPopularTvShows(page, country));
        model.addAttribute("animationMovieList", tmdbService.getAnimationMovies(page, country));
        model.addAttribute("animationTvList", tmdbService.getAnimationTvShows(page, country));
        model.addAttribute("page", page);
        model.addAttribute("country", country);
        return "movie/allList";
    }

    @RequestMapping(value = "/api/{tmdbId}", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public MovieVO movieInfo(@PathVariable int tmdbId) {
        return tmdbService.getMovieDetail(tmdbId);
    }

    @RequestMapping("/detail/{tmdbId}")
    /**
     * 영화 상세 화면에 TMDB 상세 정보, 예고편, 키워드, OTT, 내 리뷰/찜 상태를 묶어서 전달한다.
     */
    public String detail(@PathVariable int tmdbId, HttpSession session, Model model) {
        model.addAttribute("movie", tmdbService.getMovieDetail(tmdbId));
        model.addAttribute("cast", tmdbService.getCastList(tmdbId));
        model.addAttribute("crew", tmdbService.getCrewList(tmdbId));
        model.addAttribute("videos", tmdbService.getMovieVideos(tmdbId));
        model.addAttribute("keywords", tmdbService.getMovieKeywords(tmdbId));
        model.addAttribute("watchProviders", tmdbService.getMovieWatchProviders(tmdbId, "KR"));

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            MovieVO dbMovie = movieDAO.selectMovieByTmdbId(tmdbId);
            if (dbMovie != null) {
                ReviewVO myReview = new ReviewVO();
                myReview.setMovieNo(dbMovie.getMovieNo());
                myReview.setUserNo(loginUser.getUserNo());
                model.addAttribute("myReview", reviewService.getMyReview(myReview));

                WatchlistVO watchVO = new WatchlistVO();
                watchVO.setUserNo(loginUser.getUserNo());
                watchVO.setMovieNo(dbMovie.getMovieNo());
                model.addAttribute("myWatch", watchlistService.getWatch(watchVO));
            }
        }
        return "movie/detail";
    }

    @RequestMapping("/tv/{tmdbId}")
    /**
     * 드라마 상세 화면을 구성하고 선택 시즌의 예고편이 없으면 시즌1, 시리즈 전체 순서로 fallback한다.
     */
    public String tvDetail(@PathVariable int tmdbId,
                           @RequestParam(required = false) Integer seasonNo,
                           Model model) {
        MediaContentVO tv = tmdbService.getTvDetail(tmdbId);
        model.addAttribute("tv", tv);
        model.addAttribute("keywords", tmdbService.getTvKeywords(tmdbId));
        model.addAttribute("cast", tmdbService.getTvCastList(tmdbId));
        model.addAttribute("crew", tmdbService.getTvCrewList(tmdbId));
        model.addAttribute("watchProviders", tmdbService.getTvWatchProviders(tmdbId, "KR"));
        Integer selectedSeasonNo = resolveSeasonNo(tv, seasonNo);
        model.addAttribute("selectedSeasonNo", selectedSeasonNo);
        List<Map<String, Object>> seasonVideos = new ArrayList<>();
        List<Map<String, Object>> videos = new ArrayList<>();
        String videoFallbackLabel = null;
        if (selectedSeasonNo != null) {
            SeasonVO selectedSeason = tmdbService.getTvSeasonDetail(tmdbId, selectedSeasonNo);
            model.addAttribute("selectedSeason", selectedSeason);
            seasonVideos = tmdbService.getTvSeasonVideoList(tmdbId, selectedSeasonNo);
            videos = seasonVideos;

            if (videos.isEmpty() && selectedSeasonNo != 1) {
                videos = tmdbService.getTvSeasonVideoList(tmdbId, 1);
                if (!videos.isEmpty()) {
                    videoFallbackLabel = "season1";
                }
            }
        }
        model.addAttribute("seasonVideos", seasonVideos);
        if (videos.isEmpty()) {
            videos = tmdbService.getTvVideoList(tmdbId);
            if (!videos.isEmpty() && selectedSeasonNo != null) {
                videoFallbackLabel = "series";
            }
        }
        model.addAttribute("videoFallbackLabel", videoFallbackLabel);
        model.addAttribute("videos", videos);
        return "movie/tvDetail";
    }

    private Integer resolveSeasonNo(MediaContentVO tv, Integer seasonNo) {
        if (seasonNo != null) return seasonNo;
        if (tv == null || tv.getSeasons() == null || tv.getSeasons().isEmpty()) return null;

        for (SeasonVO season : tv.getSeasons()) {
            if (season.getSeasonNumber() > 0) {
                return season.getSeasonNumber();
            }
        }
        return tv.getSeasons().get(0).getSeasonNumber();
    }

    @RequestMapping(value = "/watchlist", method = RequestMethod.POST)
    @ResponseBody
    public String toggleWatchlist(int tmdbId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";
        WatchlistVO vo = new WatchlistVO();
        vo.setUserNo(loginUser.getUserNo());
        vo.setMovieNo(tmdbId);
        return watchlistService.toggleWatch(vo);
    }

    @RequestMapping("/search")
    /**
     * 제목/키워드/#태그 통합 검색을 수행하고 로그인 사용자의 최근 검색어를 중복 없이 저장한다.
     */
    public String search(@RequestParam(defaultValue = "") String q,
                         @RequestParam(defaultValue = "1") int page,
                         @RequestParam(defaultValue = "all") String mediaType,
                         @RequestParam(defaultValue = "ALL") String country,
                         HttpSession session, Model model) {
        q = q == null ? "" : q.trim();
        MediaSearchResultVO searchResult = new MediaSearchResultVO();
        List<MediaContentVO> searchList = new ArrayList<>();
        if (!q.isEmpty()) {
            searchResult = tmdbService.searchContents(q, page, mediaType, country);
            searchList = searchResult.getContents();
            UserVO loginUser = (UserVO) session.getAttribute("loginUser");
            if (loginUser != null && page <= 1) {
                searchHistoryDAO.deleteSearchByKeyword(loginUser.getUserNo(), q);
                SearchHistoryVO history = new SearchHistoryVO();
                history.setUserNo(loginUser.getUserNo());
                history.setKeyword(q);
                history.setResultCnt(searchResult.getTotalResults());
                searchHistoryDAO.insertSearch(history);
            }
        }
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            model.addAttribute("historyList", searchHistoryDAO.selectSearchByUserNo(loginUser.getUserNo()));
        }
        model.addAttribute("searchList", searchList);
        model.addAttribute("searchResult", searchResult);
        model.addAttribute("q", q);
        model.addAttribute("page", page);
        model.addAttribute("mediaType", mediaType);
        model.addAttribute("country", country);
        return "movie/search";
    }

    @RequestMapping(value = "/search/delete", method = RequestMethod.POST)
    @ResponseBody
    public String deleteSearch(int searchNo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";
        return searchHistoryDAO.deleteSearch(searchNo, loginUser.getUserNo()) > 0 ? "ok" : "fail";
    }

    @RequestMapping(value = "/search/deleteAll", method = RequestMethod.POST)
    @ResponseBody
    public String deleteAllSearch(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";
        searchHistoryDAO.deleteAllSearch(loginUser.getUserNo());
        return "ok";
    }

    @RequestMapping("/genre")
    public String genre(@RequestParam(required = false) Integer genreId,
                        @RequestParam(defaultValue = "") String genreName,
                        @RequestParam(defaultValue = "1") int page,
                        Model model) {
        if (genreId != null) {
            MediaSearchResultVO genreResult = tmdbService.getContentsByGenre(genreId, page);
            model.addAttribute("genreList", genreResult.getContents());
            model.addAttribute("genreResult", genreResult);
        }
        model.addAttribute("genreId", genreId);
        model.addAttribute("genreName", genreName);
        model.addAttribute("page", page);
        return "movie/genre";
    }

    @RequestMapping("/person/{personId}")
    public String personDetail(@PathVariable int personId, Model model) {
        model.addAttribute("person", tmdbService.getPersonDetail(personId));
        model.addAttribute("movies", tmdbService.getPersonMovies(personId));
        return "movie/person";
    }

    @RequestMapping(value = "/watched/toggle", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    /**
     * 로그인 사용자의 '봤어요' 상태를 토글하고 Ajax 응답으로 처리 결과를 반환한다.
     */
    @ResponseBody
    public Map<String, Object> toggleWatched(@RequestParam int movieNo, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "login");
            return result;
        }
        result.put("status", watchedService.toggleWatched(loginUser.getUserId(), movieNo));
        return result;
    }

    @RequestMapping(value = "/watched/check", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> checkWatched(@RequestParam int movieNo, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        result.put("watched", loginUser != null && watchedService.isWatched(loginUser.getUserId(), movieNo));
        return result;
    }

    @RequestMapping("/upcoming")
    public String upcoming(@RequestParam(defaultValue = "1") int page, Model model) {
        model.addAttribute("movies", tmdbService.getUpcomingMovies(page));
        model.addAttribute("currentPage", page);
        return "movie/upcoming";
    }

    @RequestMapping("/trending")
    public String trending(@RequestParam(defaultValue = "week") String timeWindow, Model model) {
        model.addAttribute("movies", tmdbService.getTrendingMovies(timeWindow));
        model.addAttribute("timeWindow", timeWindow);
        return "movie/trending";
    }

    @RequestMapping(value = "/similar", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<MovieVO> similar(@RequestParam int tmdbId,
                                 @RequestParam(defaultValue = "1") int page) {
        return tmdbService.getSimilarMovies(tmdbId, page);
    }

    @RequestMapping(value = "/keywords", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<Map<String, Object>> keywords(@RequestParam int tmdbId) {
        return tmdbService.getMovieKeywords(tmdbId);
    }
}
