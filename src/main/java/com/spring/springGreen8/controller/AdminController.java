package com.spring.springGreen8.controller;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.AdminDAO;
import com.spring.springGreen8.dao.SearchHistoryDAO;
import com.spring.springGreen8.service.AdminService;
import com.spring.springGreen8.service.UserService;
import com.spring.springGreen8.util.UserSessionRegistry;
import com.spring.springGreen8.vo.ReportVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

/**
 * 관리자 페이지 요청을 처리하는 컨트롤러.
 * 대시보드, 회원 관리, 리뷰/댓글 관리, 신고 처리, 운영 통계를 담당한다.
 */
@Controller
@RequestMapping("/admin")
public class AdminController {

    private static final String BLIND_REVIEW_MESSAGE_ASCII =
            "\uC2E0\uACE0\uB85C \uC778\uD574 \uBE14\uB77C\uC778\uB4DC \uCC98\uB9AC\uB41C \uB9AC\uBDF0\uC785\uB2C8\uB2E4.";

    private static final String BLINDED_REVIEW_MESSAGE = "신고로 인해 블라인드 처리된 리뷰입니다.";

    @Autowired
    private AdminDAO adminDAO;

    @Autowired
    private SearchHistoryDAO searchHistoryDAO;

    @Autowired
    private AdminService adminService;

    @Autowired
    private UserService userService;

    // 대시보드
    @RequestMapping("/dashboard")
    public String dashboard(Model model) {
        Map<String, Object> stats = adminDAO.getDashboardStats();
        if (stats == null) {
            stats = Collections.emptyMap();
        }

        List<Map<String, Object>> popularKeywords = searchHistoryDAO.selectPopularKeywords();
        if (popularKeywords == null) {
            popularKeywords = Collections.emptyList();
        }

        model.addAttribute("stats", stats);
        model.addAttribute("popularKeywords", popularKeywords);
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
                             @RequestParam String userRole,
                             HttpSession session) {
        int result = adminDAO.updateUserRole(userNo, userRole);
        if (result <= 0) return "fail";

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser != null && loginUser.getUserNo() == userNo) {
            UserVO refreshedUser = userService.getUser(userNo);
            if (refreshedUser != null) {
                session.setAttribute("loginUser", refreshedUser);
                if (!"ADMIN".equalsIgnoreCase(refreshedUser.getUserRole())) {
                    return "self_downgraded";
                }
            }
        }

        return "ok";
    }

    // 회원 강제 탈퇴 Ajax — userNo 기반
    @RequestMapping(value = "/user/delete", method = RequestMethod.POST)
    @ResponseBody
    public String deleteUser(@RequestParam int userNo) {
        try {
            userService.withdrawUser(userNo);
            UserSessionRegistry.invalidateUserSessions(userNo);
            return "ok";
        } catch (Exception e) {
            return "fail";
        }
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
        return adminService.updateReportStatus(reportId, status);
    }

}
