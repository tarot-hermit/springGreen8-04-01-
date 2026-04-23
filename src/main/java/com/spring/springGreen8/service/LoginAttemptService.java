package com.spring.springGreen8.service;

import com.spring.springGreen8.vo.LoginAttemptVO;

public interface LoginAttemptService {

    boolean isLocked(String userId, String clientIp);

    long getRemainingLockMinutes(String userId, String clientIp);

    LoginAttemptVO recordFailure(String userId, String clientIp);

    void clearFailureState(String userId, String clientIp);

    int getMaxFailCount();

    long getLockMinutes();
}
