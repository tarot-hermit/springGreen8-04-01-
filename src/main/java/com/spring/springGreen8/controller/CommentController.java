package com.spring.springGreen8.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.dao.NotificationDAO;
import com.spring.springGreen8.service.CommentService;
import com.spring.springGreen8.service.ReviewService;
import com.spring.springGreen8.service.UserService;
import com.spring.springGreen8.vo.CommentVO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.NotificationVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/comment")
public class CommentController {

    @Autowired private CommentService     commentService;
    @Autowired private ReviewService      reviewService;
    @Autowired private UserService        userService;
    @Autowired private NotificationDAO    notificationDAO;
    @Autowired private MovieDAO           movieDAO;

    // 댓글 등록 (Ajax)
    @RequestMapping(value = "/write", method = RequestMethod.POST)
    @ResponseBody
    public String write(CommentVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        if (vo.getContent() == null || vo.getContent().trim().isEmpty()
                || vo.getContent().trim().length() > 500) {
            return "fail";
        }

        vo.setUserNo(loginUser.getUserNo());
        int result = commentService.writeComment(vo);
        if (result <= 0) return "fail";

        // 알림 발송 — 본인 리뷰 댓글 제외
        ReviewVO review = reviewService.getReviewByNo(vo.getReviewNo());
        if (review != null && review.getUserNo() != loginUser.getUserNo()) {
            UserVO reviewOwner = userService.getUser(review.getUserNo());
            if (reviewOwner != null) {
                // movie_no → tmdbId 변환
                MovieVO movie = movieDAO.selectMovieByNo(review.getMovieNo());
                int tmdbId = (movie != null) ? movie.getTmdbId() : review.getMovieNo();

                NotificationVO noti = new NotificationVO();
                noti.setReceiverMid(reviewOwner.getUserId());
                noti.setSenderMid(loginUser.getUserId());
                noti.setNotiType("COMMENT");
                noti.setRefId(tmdbId);  // ← tmdbId 저장
                noti.setMessage(loginUser.getUserId() + "님이 회원님의 리뷰에 댓글을 달았습니다.");
                notificationDAO.insertNotification(noti);
            }
        }

        return "ok";
    }

    // 댓글 목록 (Ajax)
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public List<CommentVO> list(int reviewNo) {
        return commentService.getCommentsByReviewNo(reviewNo);
    }

    // 댓글 수정 (Ajax)
    @RequestMapping(value = "/update", method = RequestMethod.POST)
    @ResponseBody
    public String update(CommentVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";
        vo.setUserNo(loginUser.getUserNo());
        return commentService.updateComment(vo) > 0 ? "ok" : "fail";
    }

    // 댓글 삭제 (Ajax)
    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public String delete(CommentVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";
        vo.setUserNo(loginUser.getUserNo());
        return commentService.deleteComment(vo) > 0 ? "ok" : "fail";
    }
}
