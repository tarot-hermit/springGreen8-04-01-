package com.spring.springGreen8.controller;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.dao.ReportDAO;
import com.spring.springGreen8.vo.ReportVO;
import com.spring.springGreen8.vo.UserVO;

@Controller
@RequestMapping("/report")
public class ReportController {

    @Autowired
    private ReportDAO reportDAO;

    // 신고 등록 (Ajax)
    @RequestMapping(value = "/insert", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> insertReport(
            @RequestParam String targetType,
            @RequestParam int    targetId,
            @RequestParam String reason,
            HttpSession session) {

        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");

        if (loginUser == null) {
            result.put("status", "login");
            result.put("msg", "로그인이 필요합니다.");
            return result;
        }

        if (reason == null || reason.trim().isEmpty() || reason.length() > 500) {
            result.put("status", "fail");
            result.put("msg", "신고 사유를 1자 이상 500자 이하로 입력해주세요.");
            return result;
        }

        // 중복 신고 확인
        int dup = reportDAO.checkDuplicate(loginUser.getUserId(), targetType, targetId);
        if (dup > 0) {
            result.put("status", "dup");
            result.put("msg", "이미 신고한 항목입니다.");
            return result;
        }

        ReportVO vo = new ReportVO();
        vo.setReporterMid(loginUser.getUserId());
        vo.setTargetType(targetType);
        vo.setTargetId(targetId);
        vo.setReason(reason.trim());

        int res = reportDAO.insertReport(vo);
        result.put("status", res > 0 ? "ok" : "fail");
        result.put("msg",    res > 0 ? "신고가 접수되었습니다." : "신고 접수에 실패했습니다.");
        return result;
    }
}
