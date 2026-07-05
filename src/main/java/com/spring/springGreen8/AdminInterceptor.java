package com.spring.springGreen8;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import com.spring.springGreen8.service.UserService;
import com.spring.springGreen8.vo.UserVO;

/**
 * 관리자 전용 URL 접근을 검사하는 인터셉터.
 * /admin/** 요청에서 로그인 여부와 ADMIN 권한을 확인한다.
 */
public class AdminInterceptor implements HandlerInterceptor {

    @Autowired
    private UserService userService;

    private boolean expectsStructuredResponse(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equalsIgnoreCase(requestedWith)) return true;

        String accept = request.getHeader("Accept");
        if (accept != null && accept.toLowerCase().contains("application/json")) return true;

        return !"GET".equalsIgnoreCase(request.getMethod());
    }

    private void writeJsonError(HttpServletResponse response, int status, String body) throws Exception {
        response.setStatus(status);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.getWriter().write(body);
    }

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {

        HttpSession session = request.getSession(false);

        // 세션 없거나 로그인 안 된 경우
        if (session == null || session.getAttribute("loginUser") == null) {
            if (expectsStructuredResponse(request)) {
                writeJsonError(response, HttpServletResponse.SC_UNAUTHORIZED, "{\"status\":\"login\"}");
                return false;
            }
            response.sendRedirect(request.getContextPath() + "/user/login");
            return false;
        }

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        UserVO latestUser = loginUser;
        if (userService != null && loginUser.getUserNo() > 0) {
            latestUser = userService.getUser(loginUser.getUserNo());
        }

        if (latestUser == null) {
            session.invalidate();
            if (expectsStructuredResponse(request)) {
                writeJsonError(response, HttpServletResponse.SC_UNAUTHORIZED, "{\"status\":\"login\"}");
                return false;
            }
            response.sendRedirect(request.getContextPath() + "/user/login");
            return false;
        }

        session.setAttribute("loginUser", latestUser);

        if (!"ADMIN".equalsIgnoreCase(latestUser.getUserRole())) {
            if (expectsStructuredResponse(request)) {
                writeJsonError(response, HttpServletResponse.SC_FORBIDDEN, "{\"status\":\"forbidden\"}");
                return false;
            }
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
