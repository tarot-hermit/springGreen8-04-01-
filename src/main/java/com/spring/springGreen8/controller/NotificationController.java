package com.spring.springGreen8.controller;

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

import com.spring.springGreen8.dao.NotificationDAO;
import com.spring.springGreen8.vo.NotificationVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/notification")
public class NotificationController {

    @Autowired
    private NotificationDAO notificationDAO;

    // 미읽음 수 조회 (nav 뱃지 Ajax 폴링용)
    @RequestMapping(value = "/count", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> countUnread(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("count", 0); return result; }
        result.put("count", notificationDAO.countUnread(loginUser.getUserId()));
        return result;
    }

    // 알림 목록 조회
    @RequestMapping(value = "/list", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<NotificationVO> getList(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return List.of();
        return notificationDAO.selectMyNotifications(loginUser.getUserId());
    }

    // 단건 읽음 처리
    @RequestMapping(value = "/read", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> markAsRead(@RequestParam int notiId,
                                          HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("status", "fail"); return result; }
        notificationDAO.markAsRead(notiId);
        result.put("status", "ok");
        return result;
    }

    // 전체 읽음 처리
    @RequestMapping(value = "/readAll", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> markAllAsRead(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("status", "fail"); return result; }
        notificationDAO.markAllAsRead(loginUser.getUserId());
        result.put("status", "ok");
        return result;
    }
}
