package com.spring.springGreen8.service;

import javax.servlet.http.HttpServletRequest;

import com.spring.springGreen8.vo.KakaoProfileVO;

/**
 * 카카오 로그인 연동 서비스 계약.
 * 인가 코드로 토큰을 교환하고 카카오 프로필을 조회하는 기능을 정의한다.
 */
public interface KakaoLoginService {
    String getAuthorizationUrl(HttpServletRequest request, String state);

    KakaoProfileVO getProfileWithCode(String code, HttpServletRequest request);
}
