package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class LoginAttemptVO {
    private String userId;
    private String clientIp;
    private int failCount;
    private Date lockUntil;
    private Date lastFailedAt;
    private Date createdAt;
    private Date updatedAt;
}
