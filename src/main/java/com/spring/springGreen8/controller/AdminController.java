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
import com.spring.springGreen8.dao.SearchHistoryDAO;
import com.spring.springGreen8.vo.ReportVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AdminDAO adminDAO;
    

	@Autowired
	private SearchHistoryDAO searchHistoryDAO;

    // 대시보드
    @RequestMapping("/dashboard")
    public String dashboard(Model model) {
        Map<String, Object> stats = adminDAO.getDashboardStats();
        model.addAttribute("stats", stats);
        return "admin/dashboard";
    }

    // 회원 목록
    @RequestMapping("/users")
    public String userList(Model model) {
        List<UserVO> users = adminDAO.getAllUsers();
        model.addAttribute("users", users);
        return "admin/userList";
    }

    // 회원 등급 변경 Ajax — userNo 기반
    @RequestMapping(value = "/user/role", method = RequestMethod.POST)
    @ResponseBody
    public String updateRole(@RequestParam int userNo,
                             @RequestParam String userRole) {
        int result = adminDAO.updateUserRole(userNo, userRole);
        return result > 0 ? "ok" : "fail";
    }

    // 회원 강제 탈퇴 Ajax — userNo 기반
    @RequestMapping(value = "/user/delete", method = RequestMethod.POST)
    @ResponseBody
    public String deleteUser(@RequestParam int userNo) {
        int result = adminDAO.deleteUser(userNo);
        return result > 0 ? "ok" : "fail";
    }

    // 리뷰 목록
    @RequestMapping("/reviews")
    public String reviewList(Model model) {
        List<ReviewVO> reviews = adminDAO.getAllReviews();
        model.addAttribute("reviews", reviews);
        return "admin/reviewList";
    }

    // 리뷰 삭제 Ajax
    @RequestMapping(value = "/review/delete", method = RequestMethod.POST)
    @ResponseBody
    public String deleteReview(@RequestParam int reviewId) {
        int result = adminDAO.deleteReview(reviewId);
        return result > 0 ? "ok" : "fail";
    }

    // 신고 목록
    @RequestMapping("/reports")
    public String reportList(Model model) {
        List<ReportVO> reports = adminDAO.getAllReports();
        model.addAttribute("reports", reports);
        return "admin/reportList";
    }

    // 신고 상태 변경 Ajax
    @RequestMapping(value = "/report/status", method = RequestMethod.POST)
    @ResponseBody
    public String updateReportStatus(@RequestParam int reportId,
                                     @RequestParam String status) {
        int result = adminDAO.updateReportStatus(reportId, status);
        return result > 0 ? "ok" : "fail";
    }
    
 // 검색어 통계 (dashboard 에서 ajax 또는 별도 페이지)
    @RequestMapping("/stats/keywords")
    public String keywordStats(Model model) {
        model.addAttribute("popularKeywords", searchHistoryDAO.selectPopularKeywords());
        return "admin/dashboard";  // dashboard 에 함께 표시
    }
}
