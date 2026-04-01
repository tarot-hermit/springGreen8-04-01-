package com.spring.springGreen8.controller;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.service.ReviewService;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/review")
public class ReviewController {

		
	@Autowired
	private ReviewService reviewService;
	
	@Autowired
	private MovieDAO movieDAO;
	
	@RequestMapping(value = "/write", method = RequestMethod.POST)
	@ResponseBody
	public String write(ReviewVO vo , HttpSession session) {
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		if (loginUser == null) return "login";
		
		// movieNo 자리에 tmdbId가 들어옴
		vo.setUserNo(loginUser.getUserNo());
		int result = reviewService.writeReview(vo);
		return result > 0 ? "ok" : "fail";
	}
	
	@RequestMapping(value = "/list", method = RequestMethod.GET)
	@ResponseBody
	public List<ReviewVO> list(int movieNo) {
	    // movieNo 자리에 tmdbId가 들어옴 → 내부 movie_no 로 변환
	    MovieVO movie = movieDAO.selectMovieByTmdbId(movieNo);
	    if (movie == null) return new ArrayList<>();
	    return reviewService.getReviewsByMovieNo(movie.getMovieNo());
	}
	
	// 리뷰 수정 (Ajax)
	@RequestMapping(value = "/update" , method = RequestMethod.POST)
	@ResponseBody
	public String update(ReviewVO vo , HttpSession session) {
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		if (loginUser == null) return "login";
		vo.setUserNo(loginUser.getUserNo());
		int result = reviewService.updateReview(vo);
		return result > 0 ? "ok" : "fail";	
	}
	// 리뷰 삭제 (Ajax)
	 @RequestMapping(value = "/delete", method = RequestMethod.POST)
	 @ResponseBody
	 public String delete(ReviewVO vo , HttpSession session) {
		 UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		 if (loginUser == null) return "login";
		 vo.setUserNo(loginUser.getUserNo());
		 int result = reviewService.deleteReview(vo);
		 return result > 0 ? "ok" : "fail";
	 }
	
	
	// 공감 토글(Ajax)
	 @RequestMapping(value = "/like", method = RequestMethod.POST)
	 @ResponseBody
	 public String like(int reviewNo, HttpSession session) {
	     UserVO loginUser = (UserVO) session.getAttribute("loginUser");
	     if (loginUser == null) return "login";

	     // 본인 리뷰인지 확인
	     ReviewVO review = reviewService.getReviewByNo(reviewNo);
	     if (review != null && review.getUserNo() == loginUser.getUserNo()) {
	         return "own";  // 본인 리뷰 차단
	     }

	     return reviewService.toggleLike(reviewNo, loginUser.getUserNo());
	 }
	
	
	
	
	
	
}
