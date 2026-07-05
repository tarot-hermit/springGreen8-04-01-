package com.spring.springGreen8.vo;

import lombok.Data;

@Data
/**
 * 카카오 로그인 API에서 받은 사용자 프로필 정보를 담는 값 객체.
 */
public class KakaoProfileVO {
    private String kakaoId;
    private String nickname;
    private String email;
}
