package com.spring.springGreen8.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.service.CommentService;
import com.spring.springGreen8.vo.CommentVO;
import com.spring.springGreen8.vo.UserVO;

/**
 * 리뷰 댓글과 답글 요청을 처리하는 컨트롤러.
 * 댓글 작성/수정/삭제와 2-depth 답글 저장, 알림 생성 흐름의 진입점이다.
 */
@Controller
@RequestMapping("/comment")
public class CommentController {

    @Autowired
    private CommentService commentService;

    @RequestMapping(value = "/write", method = RequestMethod.POST)
    @ResponseBody
    public String write(CommentVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        if (vo.getParentId() != null && vo.getParentId() <= 0) {
            vo.setParentId(null);
        }

        if (vo.getContent() == null || vo.getContent().trim().isEmpty()
                || vo.getContent().trim().length() > 500) {
            return "fail";
        }

        vo.setUserNo(loginUser.getUserNo());
        try {
            return commentService.writeComment(vo, loginUser.getUserId()) > 0 ? "ok" : "fail";
        } catch (RuntimeException e) {
            return "fail";
        }
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    @ResponseBody
    public List<CommentVO> list(int reviewNo) {
        return commentService.getCommentsByReviewNo(reviewNo);
    }

    @RequestMapping(value = "/update", method = RequestMethod.POST)
    @ResponseBody
    public String update(CommentVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        CommentVO original = commentService.getCommentByNo(vo.getCommentNo());
        if (original == null || original.getUserNo() != loginUser.getUserNo()) {
            return "auth";
        }

        vo.setUserNo(loginUser.getUserNo());
        return commentService.updateComment(vo) > 0 ? "ok" : "fail";
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    @ResponseBody
    public String delete(CommentVO vo, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "login";

        CommentVO original = commentService.getCommentByNo(vo.getCommentNo());
        if (original == null) return "fail";

        boolean isOwner = original.getUserNo() == loginUser.getUserNo();
        boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getUserRole());

        if (!isOwner && !isAdmin) return "auth";

        // 관리자가 타인 댓글 삭제 시 삭제 권한 부여를 위해 userNo를 원본 값으로 설정
        vo.setUserNo(original.getUserNo());
        return commentService.deleteComment(vo) > 0 ? "ok" : "fail";
    }

}
