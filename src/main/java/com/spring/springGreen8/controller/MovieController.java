package com.spring.springGreen8.controller;

import java.util.ArrayList;
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
import com.spring.springGreen8.service.WatchlistService;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.SearchHistoryVO;
import com.spring.springGreen8.vo.UserVO;
import com.spring.springGreen8.vo.WatchlistVO;

@Controller
@RequestMapping("/movie")
public class MovieController {

    @Autowired
    private TmdbService tmdbService;
    
    @Autowired
    private MovieDAO movieDAO;
    
    @Autowired
    private WatchlistService watchlistService;

    @Autowired
    private ReviewService reviewService;
    
    @Autowired
    private SearchHistoryDAO searchHistoryDAO;

    // 영화 목록 (인기)
    @RequestMapping("/list")
    public String list(
            @RequestParam(defaultValue = "1") int page,
            Model model) {
        List<MovieVO> popularList = tmdbService.getPopularMovies(page);
        List<MovieVO> nowPlayingList = tmdbService.getNowPlayingMovies(1);
        List<MovieVO> topRatedList = tmdbService.getTopRatedMovies(1);

        model.addAttribute("popularList", popularList);
        model.addAttribute("nowPlayingList", nowPlayingList);
        model.addAttribute("topRatedList", topRatedList);
        model.addAttribute("page", page);
        return "movie/list";
    }

    // 영화 상세
    @RequestMapping("/detail/{tmdbId}")
    public String detail(@PathVariable int tmdbId,
                         HttpSession session, Model model) {
        MovieVO movie = tmdbService.getMovieDetail(tmdbId);
        model.addAttribute("movie", movie);

        // 출연진 (상위 16명, 이미 ServiceImpl에서 처리됨)
        model.addAttribute("cast", tmdbService.getCastList(tmdbId));

        // 스태프 (감독·각본 등 주요직책, 이미 ServiceImpl에서 처리됨)
        model.addAttribute("crew", tmdbService.getCrewList(tmdbId));

        // 예고편 (YouTube only, 한국어 없으면 영어 fallback, 이미 ServiceImpl에서 처리됨)
        model.addAttribute("videos", tmdbService.getVideoList(tmdbId));

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null) {
            MovieVO dbMovie = movieDAO.selectMovieByTmdbId(tmdbId);
            if (dbMovie != null) {
                ReviewVO myReview = new ReviewVO();
                myReview.setMovieNo(dbMovie.getMovieNo());
                myReview.setUserNo(loginUser.getUserNo());
                ReviewVO existReview = reviewService.getMyReview(myReview);
                model.addAttribute("myReview", existReview);

                WatchlistVO watchVO = new WatchlistVO();
                watchVO.setUserNo(loginUser.getUserNo());
                watchVO.setMovieNo(dbMovie.getMovieNo());
                WatchlistVO myWatch = watchlistService.getWatch(watchVO);
                model.addAttribute("myWatch", myWatch);
            }
        }
        return "movie/detail";
    }

   
    
 // 찜하기 토글 (Ajax)
    @RequestMapping(value = "/watchlist", method = RequestMethod.POST)
    @ResponseBody
    public String toggleWatchlist(int tmdbId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        WatchlistVO vo = new WatchlistVO();
        vo.setUserNo(loginUser.getUserNo());
        vo.setMovieNo(tmdbId);  // tmdbId 전달 → Service에서 변환
        return watchlistService.toggleWatch(vo);
    }
    
    @RequestMapping("/search")
    public String search(
    		@RequestParam(defaultValue = "") String q,
    		@RequestParam(defaultValue = "1")int page,
    		HttpSession session, Model model) {
    	
    	List<MovieVO> searchList = new ArrayList<>();
    	
    	if (!q.isEmpty()) {
    		searchList = tmdbService.searchMovies(q, page);
    		
    		// 로그인 유저면 검색 기록 저장
    		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
    		if (loginUser != null) {
    			SearchHistoryVO history = new SearchHistoryVO();
    			history.setUserNo(loginUser.getUserNo());
    			history.setKeyword(q);
    			history.setResultCnt(searchList.size());
    			searchHistoryDAO.insertSearch(history);
    		}
    	}
    	
    	// 로그인 유저면 최근 검색어 조회
    	UserVO loginUser = (UserVO) session.getAttribute("loginUser");
    	if (loginUser != null) {
    		List<SearchHistoryVO> historyList = 
    				searchHistoryDAO.selectSearchByUserNo(loginUser.getUserNo());
    		model.addAttribute("historyList",historyList);
    	}
    	model.addAttribute("searchList", searchList);
    	model.addAttribute("q",q);
    	model.addAttribute("page",page);
    	return "movie/search";   	
    }
    
    // 검색 기록 삭제 (Ajax)
    @RequestMapping(value = "/search/delete" , method = RequestMethod.POST)
    @ResponseBody
    public String deleteSearch(int searchNo, HttpSession session) {
    	UserVO loginUser = (UserVO) session.getAttribute("loginUser");
    	if (loginUser == null) return "login";
    	searchHistoryDAO.deleteSearch(searchNo);
    	return "";
    }
    
    // 검색 기록 전체 삭제(Ajax)
    @RequestMapping(value = "search/deleteAll" , method = RequestMethod.POST)
    @ResponseBody
    public String deleteAllSearch(HttpSession session) {
    	UserVO loginUser = (UserVO) session.getAttribute("loginUser");
    	if (loginUser == null) return "login";
    	searchHistoryDAO.deleteAllSearch(loginUser.getUserNo());
    	return "ok";
    }
    
 // 장르별 영화 목록
    @RequestMapping("/genre")
    public String genre(
    		@RequestParam(required = false) Integer genreId,
    		@RequestParam(defaultValue = "") String genreName,
    		@RequestParam(defaultValue = "1") int page,
    		Model model) {
    	
    	if(genreId != null) {
    		List<MovieVO> genreList = tmdbService.getMoviesByGenre(genreId, page);
    		model.addAttribute("genreList", genreList);
    	}
    	
    	model.addAttribute("genreId", genreId);
    	model.addAttribute("genreName", genreName);
    	model.addAttribute("page", page);
    	
    	return "movie/genre";
    }
    @RequestMapping("/person/{personId}")
    public String personDetail(@PathVariable int personId, Model model) {
        Map<String, Object> person = tmdbService.getPersonDetail(personId);
        List<Map<String, Object>> movies = tmdbService.getPersonMovies(personId);
        model.addAttribute("person", person);
        model.addAttribute("movies", movies);
        return "movie/person";
    }
    
    
    
}