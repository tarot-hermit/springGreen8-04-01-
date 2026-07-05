package com.spring.springGreen8.util;

import java.util.Locale;
import java.util.regex.Pattern;

/**
 * 회원/리뷰/댓글/신고/검색 입력값을 공통 검증하는 유틸리티.
 * 컨트롤러별 중복 검증을 줄이고 서버 기준 검증 규칙을 한곳에 모은다.
 */
public class InputValidator {

    public static final String ID_REGEX = "^[a-zA-Z0-9]{4,20}$";
    public static final String PW_REGEX = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,20}$";
    public static final String EMAIL_REGEX = "^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$";
    public static final String NICKNAME_REGEX = "^[가-힣a-zA-Z0-9]{2,10}$";

    // 아이디 — 영문+숫자 4~20자
    private static final Pattern ID_PATTERN =
            Pattern.compile(ID_REGEX);

    // 비밀번호 — 영문+숫자+특수문자(!@#$%^&*) 필수, 8~20자
    private static final Pattern PW_PATTERN =
            Pattern.compile(PW_REGEX);

    // 이메일
    private static final Pattern EMAIL_PATTERN =
            Pattern.compile(EMAIL_REGEX);

    // 닉네임 — 한글+영문+숫자 2~10자
    private static final Pattern NICKNAME_PATTERN =
            Pattern.compile(NICKNAME_REGEX);

    private static final Pattern AUTH_CODE_PATTERN =
            Pattern.compile("^\\d{6}$");

    private static final Pattern IMAGE_EXTENSION_PATTERN =
            Pattern.compile("(?i)\\.(png|jpg|jpeg|gif)$");

    private static final byte[] PNG_SIGNATURE =
            new byte[] {(byte) 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};

    private static final byte[] JPEG_SIGNATURE =
            new byte[] {(byte) 0xFF, (byte) 0xD8, (byte) 0xFF};

    private static final byte[] GIF87A_SIGNATURE =
            new byte[] {'G', 'I', 'F', '8', '7', 'a'};

    private static final byte[] GIF89A_SIGNATURE =
            new byte[] {'G', 'I', 'F', '8', '9', 'a'};

    // 정규식 검사는 1차 방어선이다. 실제 SQL은 반드시 MyBatis 바인딩 파라미터로 처리한다.
    private static final Pattern SQL_TAUTOLOGY_PATTERN =
            Pattern.compile(
                "(?i)(?:'|\")?\\s*(?:or|and)\\s+(?:'[^']*'|\"[^\"]*\"|\\d+)\\s*=\\s*(?:'[^']*'|\"[^\"]*\"|\\d+)"
            );

    private static final Pattern SQL_UNION_PATTERN =
            Pattern.compile("(?i)\\bunion\\b(?:\\s+all)?\\s+\\bselect\\b");

    private static final Pattern SQL_COMMAND_PATTERN =
            Pattern.compile(
                "(?i)(?:^|[\\s'\"`()])(?:select\\s+.+\\s+from|insert\\s+into|update\\s+\\w+\\s+set|delete\\s+from|drop\\s+table|alter\\s+table|truncate\\s+table|exec(?:ute)?\\s+|waitfor\\s+delay|benchmark\\s*\\(|sleep\\s*\\(|xp_cmdshell\\b|information_schema\\b)"
            );

    private static final Pattern SQL_COMMENT_WITH_KEYWORD_PATTERN =
            Pattern.compile(
                "(?i)(?:--|/\\*|\\*/).*(?:\\bselect\\b|\\bunion\\b|\\bdrop\\b|\\binsert\\b|\\bupdate\\b|\\bdelete\\b|\\bexec(?:ute)?\\b)"
            );

    private static final Pattern SQL_STACKED_QUERY_PATTERN =
            Pattern.compile("(?i);\\s*(?:select|insert|update|delete|drop|alter|truncate|exec(?:ute)?|create)\\b");

    // XSS 필터의 1차 판별용 패턴. 출력 시에는 화면별 escaping 정책도 함께 지켜야 한다.
    private static final Pattern XSS_DANGEROUS_TAG_PATTERN =
            Pattern.compile("(?i)<\\s*(script|iframe|object|embed|svg|meta|link|style|base)\\b");

    private static final Pattern XSS_EVENT_HANDLER_PATTERN =
            Pattern.compile("(?i)<[^>]+\\s+on[a-z]+\\s*=");

    private static final Pattern XSS_DANGEROUS_URI_PATTERN =
            Pattern.compile("(?i)<[^>]+\\s(?:href|src|action|formaction)\\s*=\\s*(['\"]?)\\s*(?:javascript:|vbscript:|data\\s*:\\s*text/html)");

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

    public static boolean isValidAuthCode(String code) {
        return code != null && AUTH_CODE_PATTERN.matcher(code.trim()).matches();
    }

    public static boolean isValidImageExtension(String fileName) {
        return fileName != null && IMAGE_EXTENSION_PATTERN.matcher(fileName.trim()).find();
    }

    public static String detectImageSignatureExtension(byte[] fileBytes) {
        if (fileBytes == null) return null;
        if (startsWith(fileBytes, PNG_SIGNATURE)) return ".png";
        if (startsWith(fileBytes, JPEG_SIGNATURE)) return ".jpg";
        if (startsWith(fileBytes, GIF87A_SIGNATURE) || startsWith(fileBytes, GIF89A_SIGNATURE)) return ".gif";
        return null;
    }

    public static boolean matchesImageContent(String fileName, String detectedExtension) {
        if (!isValidImageExtension(fileName) || detectedExtension == null) return false;

        String lowerName = fileName.trim().toLowerCase(Locale.ROOT);
        if (lowerName.endsWith(".jpeg")) return ".jpg".equals(detectedExtension);
        return lowerName.endsWith(detectedExtension);
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
        if (input == null) return false;
        String normalized = input.replaceAll("\\s+", " ").trim();
        return SQL_TAUTOLOGY_PATTERN.matcher(normalized).find()
            || SQL_UNION_PATTERN.matcher(normalized).find()
            || SQL_COMMAND_PATTERN.matcher(normalized).find()
            || SQL_COMMENT_WITH_KEYWORD_PATTERN.matcher(normalized).find()
            || SQL_STACKED_QUERY_PATTERN.matcher(normalized).find();
    }

    /** XSS 위험 패턴 탐지 */
    public static boolean hasXss(String input) {
        if (input == null) return false;
        return XSS_DANGEROUS_TAG_PATTERN.matcher(input).find()
            || XSS_EVENT_HANDLER_PATTERN.matcher(input).find()
            || XSS_DANGEROUS_URI_PATTERN.matcher(input).find();
    }

    /** null·공백 → 빈 문자열, 아니면 trim */
    public static String trimToEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    /** 하나라도 null 이거나 trim 결과가 빈 문자열이면 true */
    public static boolean isBlank(String... values) {
        if (values == null) return true;
        for (String v : values) {
            if (v == null || v.trim().isEmpty()) return true;
        }
        return false;
    }

    // ── 내부 유틸 ─────────────────────────────────────────────────

    private static boolean startsWith(byte[] data, byte[] prefix) {
        if (data.length < prefix.length) return false;
        for (int i = 0; i < prefix.length; i++) {
            if (data[i] != prefix[i]) return false;
        }
        return true;
    }

    private InputValidator() { /* 유틸리티 클래스 — 인스턴스화 금지 */ }
}
