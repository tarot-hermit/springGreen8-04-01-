package com.spring.springGreen8;

import java.util.List;
import java.util.Locale;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.spring.springGreen8.dao.SearchHistoryDAO;
import com.spring.springGreen8.service.TmdbService;
import com.spring.springGreen8.vo.MovieVO;

@Controller
public class HomeController {

    @Autowired
    private TmdbService tmdbService;

    @Autowired
    private SearchHistoryDAO searchHistoryDAO;

    @RequestMapping(value = {"/", "/h"}, method = RequestMethod.GET)
    public String home(Locale locale, Model model) {
        List<MovieVO> popularList    = tmdbService.getPopularMovies(1);
        List<MovieVO> nowPlayingList = tmdbService.getNowPlayingMovies(1);
        List<MovieVO> trendingList   = tmdbService.getTrendingMovies("week");
        List<MovieVO> upcomingList   = tmdbService.getUpcomingMovies(1);

        model.addAttribute("popularList",    popularList);
        model.addAttribute("nowPlayingList", nowPlayingList);
        model.addAttribute("trendingList",   trendingList);
        model.addAttribute("upcomingList",   upcomingList);
        model.addAttribute("popularKeywords", searchHistoryDAO.selectPopularKeywords());
        return "home";
    }
}
