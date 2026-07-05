package com.spring.springGreen8.controller;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Collections;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import com.spring.springGreen8.dao.AdminDAO;
import com.spring.springGreen8.dao.SearchHistoryDAO;
import com.spring.springGreen8.vo.UserVO;

/**
 * 모든 화면에서 공통으로 필요한 모델 데이터를 주입한다.
 * 로그인 사용자, 인기 검색어, 관리자 통계처럼 여러 JSP가 함께 쓰는 값을 제공한다.
 */
@ControllerAdvice
public class GlobalViewOptionsAdvice {

    private static final String ADMIN_STATS_REQUEST_ATTR =
            GlobalViewOptionsAdvice.class.getName() + ".adminStats";

    @Autowired
    private SearchHistoryDAO searchHistoryDAO;

    @Autowired
    private AdminDAO adminDAO;

    @ModelAttribute("countryOptions")
    public Map<String, String> countryOptions() {
        Map<String, String> options = new LinkedHashMap<>();
        options.put("ALL", "전체 국가");
        options.put("KR", "한국");
        options.put("JP", "일본");
        options.put("US", "미국");
        options.put("GB", "영국");
        options.put("FR", "프랑스");
        options.put("DE", "독일");
        options.put("ES", "스페인");
        options.put("IT", "이탈리아");
        options.put("CN", "중국");
        options.put("TW", "대만");
        options.put("HK", "홍콩");
        options.put("IN", "인도");
        options.put("CA", "캐나다");
        options.put("AU", "호주");
        return options;
    }

    @ModelAttribute("popularKeywords")
    public List<Map<String, Object>> popularKeywords(HttpServletRequest request) {
        if (!needsPopularKeywords(request)) return Collections.emptyList();
        try {
            List<Map<String, Object>> keywords = searchHistoryDAO.selectPopularKeywords();
            return keywords != null ? keywords : Collections.emptyList();
        } catch (Exception e) {
            // search_history 테이블 미생성 등 DB 오류 시 홈 화면 크래시 방지
            return Collections.emptyList();
        }
    }

    @ModelAttribute("pendingReportCnt")
    public int pendingReportCount(HttpServletRequest request) {
        if (!isGetRequest(request) || !isAdminUser(getLoginUser(request))) return 0;

        Object pendingCount = resolveAdminStats(request).get("pendingReportCnt");
        if (pendingCount instanceof Number) {
            return ((Number) pendingCount).intValue();
        }
        return 0;
    }

    private boolean needsPopularKeywords(HttpServletRequest request) {
        if (!isGetRequest(request)) return false;
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        return uri.equals(contextPath + "/")
                || uri.equals(contextPath + "/h")
                || uri.startsWith(contextPath + "/movie/search");
    }

    private boolean isGetRequest(HttpServletRequest request) {
        return "GET".equalsIgnoreCase(request.getMethod());
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> resolveAdminStats(HttpServletRequest request) {
        Object cached = request.getAttribute(ADMIN_STATS_REQUEST_ATTR);
        if (cached instanceof Map<?, ?>) {
            return (Map<String, Object>) cached;
        }

        Map<String, Object> stats = adminDAO.getDashboardStats();
        if (stats == null) {
            stats = Collections.emptyMap();
        }
        request.setAttribute(ADMIN_STATS_REQUEST_ATTR, stats);
        return stats;
    }

    private UserVO getLoginUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        return (UserVO) session.getAttribute("loginUser");
    }

    private boolean isAdminUser(UserVO loginUser) {
        return loginUser != null && "ADMIN".equals(loginUser.getUserRole());
    }
}
