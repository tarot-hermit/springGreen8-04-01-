package com.spring.springGreen8.controller;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.service.WatchedService;
import com.spring.springGreen8.vo.UserVO;
import com.spring.springGreen8.vo.WatchedVO;

/**
 * 사용자의 '봤어요' 기록을 처리하는 컨트롤러.
 * 콘텐츠 시청 완료 토글 요청을 받아 개인 기록 테이블과 연결한다.
 */
@Controller
@RequestMapping("/watched")
public class WatchedController {

    @Autowired private WatchedService watchedService;

    // ── 봤어요 목록 조회 (mypage Ajax) ───────────────────────────
    @RequestMapping(value = "/list", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<WatchedVO> myWatchedList(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return List.of();
        return watchedService.getMyWatched(loginUser.getUserId());
    }
}
