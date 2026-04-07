package com.spring.springGreen8;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import com.spring.springGreen8.vo.UserVO;

public class AdminInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        HttpSession session = request.getSession(false);

        // 세션 없거나 로그인 안 된 경우
        if (session == null || session.getAttribute("loginUser") == null) {
            response.sendRedirect(request.getContextPath() + "/user/login");
            return false;
        }

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (!"ADMIN".equals(loginUser.getUserRole())) {
            response.sendRedirect(request.getContextPath() + "/");
            return false;
        }

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request,
                           HttpServletResponse response,
                           Object handler,
                           ModelAndView modelAndView) throws Exception {
    }

    @Override
    public void afterCompletion(HttpServletRequest request,
                                HttpServletResponse response,
                                Object handler,
                                Exception ex) throws Exception {
    }
}
