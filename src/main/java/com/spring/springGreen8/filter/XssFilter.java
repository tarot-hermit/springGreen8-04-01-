package com.spring.springGreen8.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

public class XssFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;

        // 파일 업로드(multipart) 요청은 래핑 생략 — 파일 데이터 손상 방지
        String contentType = httpRequest.getContentType();
        if (contentType != null && contentType.toLowerCase().contains("multipart")) {
            chain.doFilter(request, response);
        } else {
            chain.doFilter(new XssRequestWrapper(httpRequest), response);
        }
    }

    @Override
    public void destroy() {}
}
