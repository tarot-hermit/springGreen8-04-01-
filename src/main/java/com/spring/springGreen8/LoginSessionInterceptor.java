package com.spring.springGreen8;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import com.spring.springGreen8.service.UserService;
import com.spring.springGreen8.util.UserSessionRegistry;
import com.spring.springGreen8.vo.UserVO;

public class LoginSessionInterceptor implements HandlerInterceptor {

    @Autowired
    private UserService userService;

    private boolean isAjaxRequest(HttpServletRequest request) {
        String requestedWith = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equalsIgnoreCase(requestedWith);
    }

    private boolean wantsJsonResponse(HttpServletRequest request) {
        String accept = request.getHeader("Accept");
        if (accept != null && accept.toLowerCase().contains("application/json")) return true;

        String contentType = request.getContentType();
        return contentType != null && contentType.toLowerCase().contains("application/json");
    }

    private void writeLoginRequired(HttpServletRequest request,
                                    HttpServletResponse response) throws Exception {
        if (wantsJsonResponse(request)) {
            response.setCharacterEncoding("UTF-8");
            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().write("{\"status\":\"login\"}");
            return;
        }

        if (isAjaxRequest(request)) {
            response.setCharacterEncoding("UTF-8");
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("login");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/user/login");
    }

    private void blockUnauthenticated(HttpServletRequest request,
                                      HttpServletResponse response) throws Exception {
        writeLoginRequired(request, response);
    }

    private void expireLoginSession(HttpServletRequest request,
                                    HttpServletResponse response,
                                    HttpSession session) throws Exception {
        if (session != null) {
            session.invalidate();
        }
        writeLoginRequired(request, response);
    }

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        HttpSession session = request.getSession(false);
        if (session == null) {
            writeLoginRequired(request, response);
            return false;
        }

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            blockUnauthenticated(request, response);
            return false;
        }

        UserVO latestUser = null;
        if (userService != null && loginUser.getUserNo() > 0) {
            latestUser = userService.getUser(loginUser.getUserNo());
        }

        if (latestUser == null) {
            expireLoginSession(request, response, session);
            return false;
        }

        session.setAttribute("loginUser", latestUser);
        UserSessionRegistry.register(latestUser, session);
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
