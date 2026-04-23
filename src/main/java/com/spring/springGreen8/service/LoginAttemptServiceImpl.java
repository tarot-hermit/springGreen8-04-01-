package com.spring.springGreen8.service;

import java.util.Date;
import java.util.concurrent.TimeUnit;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.LoginAttemptDAO;
import com.spring.springGreen8.util.InputValidator;
import com.spring.springGreen8.vo.LoginAttemptVO;

@Service
@Transactional(readOnly = true)
public class LoginAttemptServiceImpl implements LoginAttemptService {

    private static final Logger log = LoggerFactory.getLogger(LoginAttemptServiceImpl.class);

    private static final int MAX_FAIL_COUNT = 5;
    private static final long LOCK_MINUTES = 10;
    private static final long ATTEMPT_WINDOW_MINUTES = 15;

    @Autowired
    private LoginAttemptDAO loginAttemptDAO;

    @Override
    public boolean isLocked(String userId, String clientIp) {
        try {
            LoginAttemptVO attempt = getAttempt(userId, clientIp);
            if (attempt == null) return false;

            Date now = new Date();
            if (shouldReset(attempt, now)) {
                clearFailureState(userId, clientIp);
                return false;
            }
            return attempt.getLockUntil() != null && attempt.getLockUntil().after(now);
        } catch (RuntimeException e) {
            log.warn("로그인 잠금 조회 실패 userId=" + userId + ", clientIp=" + clientIp, e);
            return false;
        }
    }

    @Override
    public long getRemainingLockMinutes(String userId, String clientIp) {
        try {
            LoginAttemptVO attempt = getAttempt(userId, clientIp);
            if (attempt == null || attempt.getLockUntil() == null) return 0;

            long remainMillis = attempt.getLockUntil().getTime() - System.currentTimeMillis();
            if (remainMillis <= 0) {
                clearFailureState(userId, clientIp);
                return 0;
            }
            return (remainMillis + TimeUnit.MINUTES.toMillis(1) - 1) / TimeUnit.MINUTES.toMillis(1);
        } catch (RuntimeException e) {
            log.warn("로그인 잠금 잔여 시간 조회 실패 userId=" + userId + ", clientIp=" + clientIp, e);
            return 0;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public LoginAttemptVO recordFailure(String userId, String clientIp) {
        LoginAttemptVO fallback = new LoginAttemptVO();
        fallback.setFailCount(1);

        try {
            String normalizedUserId = normalize(userId);
            String normalizedClientIp = normalize(clientIp);
            if (normalizedUserId.isEmpty() || normalizedClientIp.isEmpty()) return fallback;

            loginAttemptDAO.deleteExpiredAttempts();

            LoginAttemptVO key = new LoginAttemptVO();
            key.setUserId(normalizedUserId);
            key.setClientIp(normalizedClientIp);
            loginAttemptDAO.ensureAttemptRow(key);

            LoginAttemptVO attempt = loginAttemptDAO.selectAttemptForUpdate(normalizedUserId, normalizedClientIp);
            Date now = new Date();
            if (attempt == null) {
                attempt = key;
                attempt.setFailCount(0);
            }

            if (shouldReset(attempt, now)) {
                attempt.setFailCount(0);
                attempt.setLockUntil(null);
            }

            if (attempt.getLockUntil() != null && attempt.getLockUntil().after(now)) {
                return attempt;
            }

            attempt.setFailCount(attempt.getFailCount() + 1);
            attempt.setLastFailedAt(now);
            attempt.setLockUntil(
                    attempt.getFailCount() >= MAX_FAIL_COUNT
                            ? new Date(now.getTime() + TimeUnit.MINUTES.toMillis(LOCK_MINUTES))
                            : null
            );

            loginAttemptDAO.updateAttempt(attempt);
            return attempt;
        } catch (RuntimeException e) {
            log.warn("로그인 실패 기록 저장 실패 userId=" + userId + ", clientIp=" + clientIp, e);
            return fallback;
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void clearFailureState(String userId, String clientIp) {
        try {
            String normalizedUserId = normalize(userId);
            String normalizedClientIp = normalize(clientIp);
            if (normalizedUserId.isEmpty() || normalizedClientIp.isEmpty()) return;
            loginAttemptDAO.deleteAttempt(normalizedUserId, normalizedClientIp);
        } catch (RuntimeException e) {
            log.warn("로그인 실패 기록 초기화 실패 userId=" + userId + ", clientIp=" + clientIp, e);
        }
    }

    @Override
    public int getMaxFailCount() {
        return MAX_FAIL_COUNT;
    }

    @Override
    public long getLockMinutes() {
        return LOCK_MINUTES;
    }

    private LoginAttemptVO getAttempt(String userId, String clientIp) {
        String normalizedUserId = normalize(userId);
        String normalizedClientIp = normalize(clientIp);
        if (normalizedUserId.isEmpty() || normalizedClientIp.isEmpty()) return null;
        return loginAttemptDAO.selectAttempt(normalizedUserId, normalizedClientIp);
    }

    private boolean shouldReset(LoginAttemptVO attempt, Date now) {
        if (attempt == null) return true;
        if (attempt.getLockUntil() != null && !attempt.getLockUntil().after(now)) {
            return true;
        }
        if (attempt.getLastFailedAt() == null) {
            return attempt.getFailCount() <= 0;
        }

        long elapsed = now.getTime() - attempt.getLastFailedAt().getTime();
        return elapsed > TimeUnit.MINUTES.toMillis(ATTEMPT_WINDOW_MINUTES);
    }

    private String normalize(String value) {
        return InputValidator.trimToEmpty(value);
    }
}
