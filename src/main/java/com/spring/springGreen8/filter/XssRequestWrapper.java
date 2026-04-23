package com.spring.springGreen8.filter;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.ServletInputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

public class XssRequestWrapper extends HttpServletRequestWrapper {

    private static final Pattern NULL_BYTE_PATTERN = Pattern.compile("\u0000");
    private static final Pattern DANGEROUS_BLOCK_TAG_PATTERN = Pattern.compile(
            "(?is)<\\s*(script|style|iframe|object|embed|link|meta|base)[^>]*>.*?<\\s*/\\s*\\1\\s*>"
    );
    private static final Pattern DANGEROUS_SINGLE_TAG_PATTERN = Pattern.compile(
            "(?is)<\\s*(script|style|iframe|object|embed|link|meta|base)\\b[^>]*?/?>"
    );
    private static final Pattern EVENT_HANDLER_ATTR_PATTERN = Pattern.compile(
            "(?i)(<[^>]+?)\\s+on[a-z]+\\s*=\\s*(?:\"[^\"]*\"|'[^']*'|[^\\s>]+)"
    );
    private static final Pattern DANGEROUS_URI_ATTR_PATTERN = Pattern.compile(
            "(?i)(<[^>]+?\\s(?:href|src|action|formaction)\\s*=\\s*)(['\"]?)\\s*(?:javascript:|vbscript:|data\\s*:\\s*text/html)([^>]*>)"
    );

    private final Charset bodyCharset;
    private final byte[] sanitizedBody;

    public XssRequestWrapper(HttpServletRequest request) throws IOException {
        super(request);
        this.bodyCharset = resolveCharset(request);
        this.sanitizedBody = shouldWrapBody(request) ? sanitizeBody(request.getInputStream()) : null;
    }

    @Override
    public String[] getParameterValues(String parameter) {
        String[] values = super.getParameterValues(parameter);
        if (values == null) return null;

        String[] cleaned = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            cleaned[i] = sanitizeInput(values[i]);
        }
        return cleaned;
    }

    @Override
    public String getParameter(String parameter) {
        String value = super.getParameter(parameter);
        return value == null ? null : sanitizeInput(value);
    }

    @Override
    public Map<String, String[]> getParameterMap() {
        Map<String, String[]> original = super.getParameterMap();
        Map<String, String[]> cleaned = new LinkedHashMap<String, String[]>(original.size());

        for (Map.Entry<String, String[]> entry : original.entrySet()) {
            String[] values = entry.getValue();
            if (values == null) {
                cleaned.put(entry.getKey(), null);
                continue;
            }

            String[] sanitizedValues = new String[values.length];
            for (int i = 0; i < values.length; i++) {
                sanitizedValues[i] = sanitizeInput(values[i]);
            }
            cleaned.put(entry.getKey(), sanitizedValues);
        }
        return cleaned;
    }

    @Override
    public ServletInputStream getInputStream() throws IOException {
        if (sanitizedBody == null) {
            return super.getInputStream();
        }
        return new CachedServletInputStream(sanitizedBody);
    }

    @Override
    public BufferedReader getReader() throws IOException {
        if (sanitizedBody == null) {
            return super.getReader();
        }
        return new BufferedReader(new InputStreamReader(getInputStream(), bodyCharset));
    }

    private Charset resolveCharset(HttpServletRequest request) {
        String encoding = request.getCharacterEncoding();
        if (encoding == null || encoding.trim().isEmpty()) {
            return StandardCharsets.UTF_8;
        }

        try {
            return Charset.forName(encoding);
        } catch (Exception e) {
            return StandardCharsets.UTF_8;
        }
    }

    private boolean shouldWrapBody(HttpServletRequest request) {
        String contentType = request.getContentType();
        if (contentType == null) return false;

        String normalized = contentType.toLowerCase();
        return normalized.contains("application/json")
                || normalized.contains("+json")
                || normalized.startsWith("text/");
    }

    private byte[] sanitizeBody(InputStream inputStream) throws IOException {
        byte[] body = toByteArray(inputStream);
        if (body.length == 0) return body;

        String sanitized = sanitizeInput(new String(body, bodyCharset));
        return sanitized.getBytes(bodyCharset);
    }

    private byte[] toByteArray(InputStream inputStream) throws IOException {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        byte[] chunk = new byte[1024];
        int read;

        while ((read = inputStream.read(chunk)) != -1) {
            buffer.write(chunk, 0, read);
        }
        return buffer.toByteArray();
    }

    private String sanitizeInput(String value) {
        if (value == null || value.isEmpty()) return value;

        String sanitized = NULL_BYTE_PATTERN.matcher(value).replaceAll("");
        sanitized = DANGEROUS_BLOCK_TAG_PATTERN.matcher(sanitized).replaceAll("");
        sanitized = DANGEROUS_SINGLE_TAG_PATTERN.matcher(sanitized).replaceAll("");
        sanitized = stripEventHandlerAttributes(sanitized);
        sanitized = neutralizeDangerousUriAttributes(sanitized);
        return sanitized;
    }

    private String stripEventHandlerAttributes(String value) {
        String sanitized = value;
        String previous;
        do {
            previous = sanitized;
            sanitized = EVENT_HANDLER_ATTR_PATTERN.matcher(sanitized).replaceAll("$1");
        } while (!previous.equals(sanitized));
        return sanitized;
    }

    private String neutralizeDangerousUriAttributes(String value) {
        String sanitized = value;
        String previous;
        do {
            previous = sanitized;
            sanitized = DANGEROUS_URI_ATTR_PATTERN.matcher(sanitized).replaceAll("$1$2#$3");
        } while (!previous.equals(sanitized));
        return sanitized;
    }

    private static class CachedServletInputStream extends ServletInputStream {
        private final ByteArrayInputStream inputStream;

        CachedServletInputStream(byte[] body) {
            this.inputStream = new ByteArrayInputStream(body);
        }

        @Override
        public int read() {
            return inputStream.read();
        }
    }
}
