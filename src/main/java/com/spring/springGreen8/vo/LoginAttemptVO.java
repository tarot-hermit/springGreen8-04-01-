package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
/**
 * 로그인 실패 횟수와 잠금 해제 시각을 담는 값 객체.
 */
public class LoginAttemptVO {
    private String userId;
    private String clientIp;
    private int failCount;
    private Date lockUntil;
    private Date lastFailedAt;
    private Date createdAt;
    private Date updatedAt;
}
