package com.spring.springGreen8.service;

import javax.servlet.http.HttpServletRequest;

import com.spring.springGreen8.vo.KakaoProfileVO;

public interface KakaoLoginService {
    String getAuthorizationUrl(HttpServletRequest request, String state);

    KakaoProfileVO getProfileWithCode(String code, HttpServletRequest request);
}
