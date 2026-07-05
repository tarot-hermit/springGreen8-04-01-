package com.spring.springGreen8;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import com.spring.springGreen8.util.UserSessionRegistry;

/**
 * 세션 생성/소멸 이벤트를 감지하는 리스너.
 * 로그아웃, 만료, 강제 종료 시 UserSessionRegistry에 남은 사용자 세션 정보를 정리한다.
 */
public class UserSessionListener implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent se) {
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        UserSessionRegistry.unregister(se.getSession());
    }
}
