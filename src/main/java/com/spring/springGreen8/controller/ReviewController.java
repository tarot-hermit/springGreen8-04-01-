package com.spring.springGreen8.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.service.ReviewService;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/review")
public class ReviewController {

    @Autowired private ReviewService reviewService;
    @Autowired private MovieDAO      movieDAO;

    // 리뷰 등록
    @RequestMapping(value = "/write", method = RequestMethod.POST)
    @ResponseBody
    public String write(ReviewVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        // 내용 길이 검증 (10자 이상 ~ 2000자 이하)
        if (vo.getContent() == null
                || vo.getContent().trim().length() < 10
                || vo.getContent().trim().length() > 2000) {
            return "length";
        }

        vo.setUserNo(loginUser.getUserNo());
        int result = reviewService.writeReview(vo);
        return result > 0 ? "ok" : "fail";
    }

    // 리뷰 목록
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public List<ReviewVO> list(int movieNo) {
        MovieVO movie = movieDAO.selectMovieByTmdbId(movieNo);
        if (movie == null) return new ArrayList<>();
        return reviewService.getReviewsByMovieNo(movie.getMovieNo());
    }

    // 리뷰 수정 — 내용 길이 검증 + 본인 확인
    @RequestMapping(value = "/update", method = RequestMethod.POST)
    @ResponseBody
    public String update(ReviewVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        // 내용 길이 검증
        if (vo.getContent() == null
                || vo.getContent().trim().length() < 10
                || vo.getContent().trim().length() > 2000) {
            return "length";
        }

        // 본인 확인 — DB에서 원본 조회 후 userNo 비교
        ReviewVO original = reviewService.getReviewByNo(vo.getReviewNo());
        if (original == null || original.getUserNo() != loginUser.getUserNo()) {
            return "auth";  // 권한 없음
        }

        vo.setUserNo(loginUser.getUserNo());
        int result = reviewService.updateReview(vo);
        return result > 0 ? "ok" : "fail";
    }

    // 리뷰 삭제 — 본인 확인
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public String delete(ReviewVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        // 본인 또는 관리자만 삭제 가능
        ReviewVO original = reviewService.getReviewByNo(vo.getReviewNo());
        if (original == null) return "fail";

        boolean isOwner = original.getUserNo() == loginUser.getUserNo();
        boolean isAdmin = "ADMIN".equals(loginUser.getUserRole());
        if (!isOwner && !isAdmin) return "auth";

        vo.setUserNo(loginUser.getUserNo());
        int result = reviewService.deleteReview(vo);
        return result > 0 ? "ok" : "fail";
    }

    // 공감 토글
    @RequestMapping(value = "/like", method = RequestMethod.POST)
    @ResponseBody
    public String like(int reviewNo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";
        ReviewVO review = reviewService.getReviewByNo(reviewNo);
        if (review != null && review.getUserNo() == loginUser.getUserNo()) return "own";
        return reviewService.toggleLike(reviewNo, loginUser.getUserNo());
    }

    // 정렬 옵션 리뷰 목록
    @RequestMapping(value = "/list/sorted", method = RequestMethod.GET)
    @ResponseBody
    public List<ReviewVO> listSorted(@RequestParam int movieNo,
                                     @RequestParam(defaultValue = "latest") String sort) {
        MovieVO movie = movieDAO.selectMovieByTmdbId(movieNo);
        if (movie == null) return new ArrayList<>();
        return reviewService.getReviewsSorted(movie.getMovieNo(), sort);
    }

    // 별점 분포
    @RequestMapping(value = "/stats", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<Map<String, Object>> ratingStats(@RequestParam int movieNo) {
        MovieVO movie = movieDAO.selectMovieByTmdbId(movieNo);
        if (movie == null) return new ArrayList<>();
        return reviewService.getRatingStats(movie.getMovieNo());
    }
}
