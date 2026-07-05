package com.spring.springGreen8.vo;

import java.util.Date;
import lombok.Data;

@Data
/**
 * 회원 계정, 프로필, 권한, 카카오 연동 정보를 담는 값 객체.
 */
public class UserVO {
    private int userNo;
    private String userId;
    private String userPw;
    private String userName;
    private String userEmail;
    private String userImg;
    private String userBio;
    private String userRole;
    private String userAddr1;
    private String userAddr2;
    private String userZipcode;
    private String kakaoId;
    private String loginProvider;
    private Date joinDate;
}
