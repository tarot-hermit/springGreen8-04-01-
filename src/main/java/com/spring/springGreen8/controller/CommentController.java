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

@Controller
@RequestMapping("/comment")
public class CommentController {
	
	@Autowired
	private CommentService commentService;
	
	// ´ñ±Û µî·Ï (Ajax)
	@RequestMapping(value ="/write" , method = RequestMethod.POST)
	@ResponseBody
	public String write(CommentVO vo , HttpSession session) {
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		if (loginUser == null) return "login";
		vo.setUserNo(loginUser.getUserNo());
		int result = commentService.writeComment(vo);
		return result > 0 ? "ok" : "fail";
	}
	
	// ´ñ±Û µî·Ï (Ajax)
	@RequestMapping(value = "/list" , method = RequestMethod.GET)
	@ResponseBody
	public List<CommentVO> list(int reviewNo) {
		return commentService.getCommentsByReviewNo(reviewNo);
	}
	
	// ´ñ±Û ¼öÁ¤ (Ajax)
	@RequestMapping(value = "/update" , method = RequestMethod.POST)
	@ResponseBody
	public String update(CommentVO vo , HttpSession session) {
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		if (loginUser == null) return "login";
		vo.setUserNo(loginUser.getUserNo());
		int result = commentService.updateComment(vo);
		return result > 0 ? "ok" : "fail";
	}
	// ´ñ±Û »èÁ¦ (Ajax)
	 @RequestMapping(value = "/delete", method = RequestMethod.POST)
	 @ResponseBody
	    public String delete(CommentVO vo, HttpSession session) {
	        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
	        if (loginUser == null) return "login";
	        vo.setUserNo(loginUser.getUserNo());
	        int result = commentService.deleteComment(vo);
	        return result > 0 ? "ok" : "fail";
	    }
		
		
		
		
		
		

}
