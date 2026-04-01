package com.spring.springGreen8.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.AdminDAO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/admin")
public class AdminController {
	
	@Autowired
	private AdminDAO adminDAO;
	
	// 대시보드
	@RequestMapping("/dashboard")
	public String dashboard(Model model) {
		Map<String, Object> stats = adminDAO.getDashboardStats();
		model.addAttribute("stats",stats);
		return "admin/dashboard";
	}
	
	// 회원 목록
	@RequestMapping("/users")
	public String userList(Model model) {
		List<UserVO> users = adminDAO.getAllUsers();
		model.addAttribute("users",users);
		return "admin/userList";
	}
	
	// 회원 역할 변경(Ajax)
	@RequestMapping(value = "/user/role" , method = RequestMethod.POST)
	@ResponseBody
	public String updateRole(@RequestParam int userNo,
							 @RequestParam String userRole) {
		int result = adminDAO.updateUserRole(userNo, userRole);
		return result > 0 ? "ok" : "fail";
	}
	// 회원 강제 탈퇴(Ajax)
	@RequestMapping(value = "/user/delete" , method = RequestMethod.POST)
	@ResponseBody
	public String deleteUser(@RequestParam int userNo) {
		int result = adminDAO.deleteUser(userNo);
		return result > 0 ? "ok" : "fail";
	}
	
	//리뷰 목록 
	@RequestMapping("/reviews")
	public String reviewList(Model model) {
		List<ReviewVO> reviews = adminDAO.getAllReviews();
		model.addAttribute("reviews",reviews);
		return "admin/reviewList";
	}
	// 리뷰 강제 삭제 (Ajax)
	@RequestMapping(value = "/review/delete" , method = RequestMethod.POST)
	@ResponseBody
	public String deleteReview(@RequestParam int reviewNo) {
		int result = adminDAO.deleteReview(reviewNo);
		return result > 0 ? "ok" : "fail";
	}
	
	
	
}
