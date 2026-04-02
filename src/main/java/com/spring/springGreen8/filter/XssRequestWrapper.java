package com.spring.springGreen8.filter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

public class XssRequestWrapper extends HttpServletRequestWrapper {

    public XssRequestWrapper(HttpServletRequest request) {
        super(request);
    }

    @Override
    public String[] getParameterValues(String parameter) {
        String[] values = super.getParameterValues(parameter);
        if (values == null) return null;
        String[] cleaned = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            cleaned[i] = cleanXss(values[i]);
        }
        return cleaned;
    }

    @Override
    public String getParameter(String parameter) {
        String value = super.getParameter(parameter);
        return value == null ? null : cleanXss(value);
    }

    @Override
    public String getHeader(String name) {
        String value = super.getHeader(name);
        return value == null ? null : cleanXss(value);
    }

    private String cleanXss(String value) {
        if (value == null || value.isEmpty()) return value;

        // <script> 블록 제거
        value = value.replaceAll("(?is)<script[^>]*>.*?</script>", "");
        // HTML 태그 제거
        value = value.replaceAll("(?i)<[^>]*>", "");
        // 위험 프로토콜 제거
        value = value.replaceAll("(?i)javascript\\s*:", "");
        value = value.replaceAll("(?i)vbscript\\s*:", "");
        // 이벤트 핸들러 제거
        value = value.replaceAll("(?i)on[a-z]+\\s*=", "");
        // 특수문자 엔티티 인코딩
        value = value.replace("&",  "&amp;")
                     .replace("<",  "&lt;")
                     .replace(">",  "&gt;")
                     .replace("\"", "&quot;")
                     .replace("'",  "&#x27;")
                     .replace("/",  "&#x2F;");
        return value;
    }
}
