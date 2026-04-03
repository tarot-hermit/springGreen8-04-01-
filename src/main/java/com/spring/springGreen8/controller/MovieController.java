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
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.SearchHistoryVO;
import com.spring.springGreen8.vo.UserVO;
import com.spring.springGreen8.vo.WatchlistVO;

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
    public String list(@RequestParam(defaultValue = "1") int page, Model model) {
        model.addAttribute("popularList", tmdbService.getPopularMovies(page));
        model.addAttribute("nowPlayingList", tmdbService.getNowPlayingMovies(1));
        model.addAttribute("topRatedList", tmdbService.getTopRatedMovies(1));
        model.addAttribute("page", page);
        return "movie/list";
    }

    @RequestMapping(value = "/api/{tmdbId}", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public MovieVO movieInfo(@PathVariable int tmdbId) {
        return tmdbService.getMovieDetail(tmdbId);
    }

    @RequestMapping("/detail/{tmdbId}")
    public String detail(@PathVariable int tmdbId, HttpSession session, Model model) {
        model.addAttribute("movie", tmdbService.getMovieDetail(tmdbId));
        model.addAttribute("cast", tmdbService.getCastList(tmdbId));
        model.addAttribute("crew", tmdbService.getCrewList(tmdbId));
        model.addAttribute("videos", tmdbService.getVideoList(tmdbId));

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
    public String search(@RequestParam(defaultValue = "") String q,
                         @RequestParam(defaultValue = "1") int page,
                         HttpSession session, Model model) {
        List<MovieVO> searchList = new ArrayList<>();
        if (!q.isEmpty()) {
            searchList = tmdbService.searchMovies(q, page);
            UserVO loginUser = (UserVO) session.getAttribute("loginUser");
            if (loginUser != null) {
                SearchHistoryVO history = new SearchHistoryVO();
                history.setUserNo(loginUser.getUserNo());
                history.setKeyword(q);
                history.setResultCnt(searchList.size());
                searchHistoryDAO.insertSearch(history);
            }
        }
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            model.addAttribute("historyList", searchHistoryDAO.selectSearchByUserNo(loginUser.getUserNo()));
        }
        model.addAttribute("searchList", searchList);
        model.addAttribute("q", q);
        model.addAttribute("page", page);
        model.addAttribute("popularKeywords", searchHistoryDAO.selectPopularKeywords());
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
            model.addAttribute("genreList", tmdbService.getMoviesByGenre(genreId, page));
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
