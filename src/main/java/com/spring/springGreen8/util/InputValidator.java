package com.spring.springGreen8.util;

import java.util.regex.Pattern;

public class InputValidator {

    // 아이디 — 영문+숫자 4~20자
    private static final Pattern ID_PATTERN =
            Pattern.compile("^[a-zA-Z0-9]{4,20}$");

    // 비밀번호 — 영문+숫자+특수문자(!@#$%^&*) 필수, 8~20자
    private static final Pattern PW_PATTERN =
            Pattern.compile("^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,20}$");

    // 이메일
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$");

    // 닉네임 — 한글+영문+숫자 2~10자
    private static final Pattern NICKNAME_PATTERN =
            Pattern.compile("^[가-힣a-zA-Z0-9]{2,10}$");

    // SQL Injection 위험 키워드
    private static final Pattern SQL_INJECTION_PATTERN =
            Pattern.compile(
                "(?i)(\\bselect\\b|\\binsert\\b|\\bupdate\\b|\\bdelete\\b|\\bdrop\\b" +
                "|\\bunion\\b|\\bexec\\b|\\bexecute\\b|xp_|--|;|/\\*|\\*/)"
            );

    // ── 공개 메서드 ───────────────────────────────────────────────

    public static boolean isValidId(String id) {
        return id != null && ID_PATTERN.matcher(id.trim()).matches();
    }

    public static boolean isValidPw(String pw) {
        return pw != null && PW_PATTERN.matcher(pw).matches();
    }

    public static boolean isValidEmail(String email) {
        return email != null && EMAIL_PATTERN.matcher(email.trim()).matches();
    }

    public static boolean isValidNickname(String nickname) {
        return nickname != null && NICKNAME_PATTERN.matcher(nickname.trim()).matches();
    }

    /** 리뷰 본문 길이 검사 */
    public static boolean isValidReviewContent(String content, int min, int max) {
        if (content == null) return false;
        int len = content.trim().length();
        return len >= min && len <= max;
    }

    /** 댓글 본문 길이 검사 */
    public static boolean isValidCommentContent(String content, int max) {
        if (content == null || content.trim().isEmpty()) return false;
        return content.trim().length() <= max;
    }

    /** 범용 길이 검사 */
    public static boolean isValidLength(String input, int min, int max) {
        if (input == null) return false;
        int len = input.trim().length();
        return len >= min && len <= max;
    }

    /** SQL Injection 위험 패턴 탐지 */
    public static boolean hasSqlInjection(String input) {
        return input != null && SQL_INJECTION_PATTERN.matcher(input).find();
    }

    /** XSS 위험 문자 포함 여부 (2차 검사용) */
    public static boolean hasXssRisk(String input) {
        if (input == null) return false;
        return input.contains("<") || input.contains(">")
            || input.toLowerCase().contains("javascript:");
    }

    /** null·공백 체크 (여러 필드 동시) */
    public static boolean isBlank(String... values) {
        if (values == null) return true;
        for (String v : values) {
            if (v == null || v.trim().isEmpty()) return true;
        }
        return false;
    }
}
