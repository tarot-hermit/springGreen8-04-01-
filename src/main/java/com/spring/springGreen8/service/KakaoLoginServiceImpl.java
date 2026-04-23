package com.spring.springGreen8.service;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.spring.springGreen8.vo.KakaoProfileVO;

@Service
public class KakaoLoginServiceImpl implements KakaoLoginService {

    private static final String AUTH_URL = "https://kauth.kakao.com/oauth/authorize";
    private static final String TOKEN_URL = "https://kauth.kakao.com/oauth/token";
    private static final String USER_ME_URL = "https://kapi.kakao.com/v2/user/me";

    @Value("${kakao.client.id:}")
    private String clientId;

    @Value("${kakao.client.secret:}")
    private String clientSecret;

    @Value("${kakao.redirect.uri:}")
    private String redirectUri;

    @Autowired
    private RestTemplate restTemplate;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String getAuthorizationUrl(HttpServletRequest request, String state) {
        if (clientId == null || clientId.trim().isEmpty()) {
            throw new IllegalStateException("Kakao REST API key is not configured.");
        }

        // prompt=login은 카카오 브라우저 세션이 남아 있어도 로그인 화면을 다시 띄운다.
        return UriComponentsBuilder.fromHttpUrl(AUTH_URL)
                .queryParam("client_id", clientId)
                .queryParam("redirect_uri", getRedirectUri(request))
                .queryParam("response_type", "code")
                .queryParam("prompt", "login")
                .queryParam("state", state)
                .build()
                .toUriString();
    }

    @Override
    public KakaoProfileVO getProfileWithCode(String code, HttpServletRequest request) {
        // 인가 코드로 access token을 받은 뒤 사용자 프로필 API를 호출한다.
        String accessToken = requestAccessToken(code, request);
        JsonNode profile = requestProfile(accessToken);

        String kakaoId = profile.path("id").asText();
        JsonNode kakaoAccount = profile.path("kakao_account");
        JsonNode properties = profile.path("properties");

        String nickname = properties.path("nickname").asText("");
        String email = "";
        if (kakaoAccount.path("has_email").asBoolean(false)
                && !kakaoAccount.path("email_needs_agreement").asBoolean(false)) {
            email = kakaoAccount.path("email").asText("");
        }

        if (kakaoId == null || kakaoId.trim().isEmpty()) {
            throw new IllegalStateException("Kakao profile id is empty.");
        }

        KakaoProfileVO kakaoProfile = new KakaoProfileVO();
        kakaoProfile.setKakaoId(kakaoId);
        kakaoProfile.setNickname(nickname);
        kakaoProfile.setEmail(email);
        return kakaoProfile;
    }

    private String requestAccessToken(String code, HttpServletRequest request) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("grant_type", "authorization_code");
        params.add("client_id", clientId);
        params.add("redirect_uri", getRedirectUri(request));
        params.add("code", code);
        if (clientSecret != null && !clientSecret.trim().isEmpty()) {
            params.add("client_secret", clientSecret);
        }

        ResponseEntity<String> response = restTemplate.postForEntity(
                TOKEN_URL,
                new HttpEntity<MultiValueMap<String, String>>(params, headers),
                String.class
        );

        try {
            JsonNode json = objectMapper.readTree(response.getBody());
            String accessToken = json.path("access_token").asText();
            if (accessToken == null || accessToken.trim().isEmpty()) {
                throw new IllegalStateException("Kakao access token is empty.");
            }
            return accessToken;
        } catch (Exception e) {
            throw new IllegalStateException("Failed to parse Kakao token response.", e);
        }
    }

    private JsonNode requestProfile(String accessToken) {
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);

        ResponseEntity<String> response = restTemplate.exchange(
                USER_ME_URL,
                HttpMethod.GET,
                new HttpEntity<String>(headers),
                String.class
        );

        try {
            return objectMapper.readTree(response.getBody());
        } catch (Exception e) {
            throw new IllegalStateException("Failed to parse Kakao profile response.", e);
        }
    }

    private String getRedirectUri(HttpServletRequest request) {
        if (redirectUri != null && !redirectUri.trim().isEmpty()) {
            return redirectUri.trim();
        }

        // 로컬/배포 환경에서 설정값이 없을 때 현재 요청 기준 콜백 URL을 만든다.
        StringBuilder url = new StringBuilder();
        url.append(request.getScheme()).append("://").append(request.getServerName());
        int port = request.getServerPort();
        if (("http".equals(request.getScheme()) && port != 80)
                || ("https".equals(request.getScheme()) && port != 443)) {
            url.append(":").append(port);
        }
        url.append(request.getContextPath()).append("/user/kakao/callback");
        return url.toString();
    }
}
