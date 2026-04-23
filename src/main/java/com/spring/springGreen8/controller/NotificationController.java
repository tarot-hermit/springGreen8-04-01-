package com.spring.springGreen8.controller;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.service.NotificationService;
import com.spring.springGreen8.vo.NotificationVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/notification")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @RequestMapping(value = "/count", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> countUnread(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("count", 0);
            return result;
        }
        result.put("count", notificationService.countUnread(loginUser.getUserId()));
        return result;
    }

    @RequestMapping(value = "/list", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<NotificationVO> getList(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return Collections.emptyList();
        return notificationService.getMyNotifications(loginUser.getUserId());
    }

    /**
     * 알림 클릭 시 진입점. 소유권 검증 → 읽음 처리 → 관련 페이지로 리다이렉트.
     * refId는 알림 생성 시 기록한 TMDB id(영화 상세) 또는 report_id(관리자만 의미).
     */
    @RequestMapping(value = "/open", method = RequestMethod.GET)
    public String openNotification(@RequestParam int notiId, HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/user/login";

        NotificationVO notification =
                notificationService.getNotification(notiId, loginUser.getUserId());
        if (notification == null) return "redirect:/user/mypage";

        notificationService.markAsRead(notiId, loginUser.getUserId());
        return "redirect:" + resolveRedirectPath(notification);
    }

    /**
     * 알림 타입/참조값에 따른 목적지 URL 결정.
     * - COMMENT / LIKE / REVIEW: refId를 TMDB id로 보고 영화 상세 페이지로 이동
     * - REPORT : 신고 처리 결과 알림 → 마이페이지로 이동 (신고 이력 화면이 별도로 없으므로)
     * - 그 외/비정상값 : 마이페이지로 안전 폴백
     */
    private String resolveRedirectPath(NotificationVO notification) {
        String type = notification.getNotiType();
        int refId = notification.getRefId();
        if (type == null) return "/user/mypage";

        if ("COMMENT".equalsIgnoreCase(type)
                || "LIKE".equalsIgnoreCase(type)
                || "REVIEW".equalsIgnoreCase(type)) {
            if (refId > 0) {
                return "/movie/detail/" + refId;
            }
            return "/user/mypage";
        }

        // REPORT 등은 안전 폴백
        return "/user/mypage";
    }

    @RequestMapping(value = "/read", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> markAsRead(@RequestParam int notiId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "fail");
            return result;
        }

        int updated = notificationService.markAsRead(notiId, loginUser.getUserId());
        result.put("status", updated > 0 ? "ok" : "fail");
        return result;
    }

    @RequestMapping(value = "/readAll", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> markAllAsRead(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "fail");
            return result;
        }
        notificationService.markAllAsRead(loginUser.getUserId());
        result.put("status", "ok");
        return result;
    }
}
