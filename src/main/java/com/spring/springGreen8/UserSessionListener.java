package com.spring.springGreen8;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

import com.spring.springGreen8.util.UserSessionRegistry;

public class UserSessionListener implements HttpSessionListener {

    @Override
    public void sessionCreated(HttpSessionEvent se) {
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        UserSessionRegistry.unregister(se.getSession());
    }
}
