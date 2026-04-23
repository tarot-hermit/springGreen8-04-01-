package com.spring.springGreen8.util;

import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import javax.servlet.http.HttpSession;

import com.spring.springGreen8.vo.UserVO;

public final class UserSessionRegistry {

    private static final ConcurrentMap<Integer, Set<HttpSession>> USER_SESSIONS = new ConcurrentHashMap<>();
    private static final ConcurrentMap<String, Integer> SESSION_USERS = new ConcurrentHashMap<>();

    private UserSessionRegistry() {
    }

    public static void register(UserVO user, HttpSession session) {
        if (user == null || session == null || user.getUserNo() <= 0) return;

        unregister(session);
        USER_SESSIONS
                .computeIfAbsent(user.getUserNo(), key -> ConcurrentHashMap.newKeySet())
                .add(session);
        SESSION_USERS.put(session.getId(), user.getUserNo());
    }

    public static void unregister(HttpSession session) {
        if (session == null) return;

        String sessionId = getSessionId(session);
        if (sessionId == null) return;

        Integer userNo = SESSION_USERS.remove(sessionId);
        if (userNo == null) return;

        Set<HttpSession> sessions = USER_SESSIONS.get(userNo);
        if (sessions == null) return;

        sessions.remove(session);
        if (sessions.isEmpty()) {
            USER_SESSIONS.remove(userNo, sessions);
        }
    }

    public static void invalidateUserSessions(int userNo) {
        if (userNo <= 0) return;

        Set<HttpSession> sessions = USER_SESSIONS.remove(userNo);
        if (sessions == null) return;

        for (HttpSession session : sessions) {
            String sessionId = getSessionId(session);
            if (sessionId != null) {
                SESSION_USERS.remove(sessionId);
            }
            try {
                session.invalidate();
            } catch (IllegalStateException ignored) {
            }
        }
    }

    public static void invalidateOtherUserSessions(int userNo, HttpSession currentSession) {
        if (userNo <= 0) return;

        Set<HttpSession> sessions = USER_SESSIONS.get(userNo);
        if (sessions == null) return;

        for (HttpSession session : sessions.toArray(new HttpSession[0])) {
            if (session == currentSession) continue;
            String sessionId = getSessionId(session);
            if (sessionId != null) {
                SESSION_USERS.remove(sessionId);
            }
            sessions.remove(session);
            try {
                session.invalidate();
            } catch (IllegalStateException ignored) {
            }
        }

        if (sessions.isEmpty()) {
            USER_SESSIONS.remove(userNo, sessions);
        }
    }

    private static String getSessionId(HttpSession session) {
        try {
            return session.getId();
        } catch (IllegalStateException e) {
            return null;
        }
    }
}
