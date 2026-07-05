package com.spring.springGreen8.service;

import com.spring.springGreen8.vo.LoginAttemptVO;

/**
 * 로그인 실패 관리 서비스 계약.
 * 실패 횟수 기록, 잠금 여부 판단, 성공 시 기록 초기화 기능을 정의한다.
 */
public interface LoginAttemptService {

    boolean isLocked(String userId, String clientIp);

    long getRemainingLockMinutes(String userId, String clientIp);

    LoginAttemptVO recordFailure(String userId, String clientIp);

    void clearFailureState(String userId, String clientIp);

    int getMaxFailCount();

    long getLockMinutes();
}
