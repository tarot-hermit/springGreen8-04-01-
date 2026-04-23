package com.spring.springGreen8.controller;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

import java.awt.image.BufferedImage;

import javax.imageio.ImageIO;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.digest.DigestUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.spring.springGreen8.service.EmailService;
import com.spring.springGreen8.service.KakaoLoginService;
import com.spring.springGreen8.service.CollectionService;
import com.spring.springGreen8.service.LoginAttemptService;
import com.spring.springGreen8.service.ReviewService;
import com.spring.springGreen8.service.UserService;
import com.spring.springGreen8.service.WatchedService;
import com.spring.springGreen8.service.WatchlistService;
import com.spring.springGreen8.util.InputValidator;
import com.spring.springGreen8.util.UserSessionRegistry;
import com.spring.springGreen8.vo.CollectionVO;
import com.spring.springGreen8.vo.KakaoProfileVO;
import com.spring.springGreen8.vo.LoginAttemptVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;
import com.spring.springGreen8.vo.WatchedVO;
import com.spring.springGreen8.vo.WatchlistVO;

@Controller
@RequestMapping("/user")
public class UserController {

    private static final Logger log = LoggerFactory.getLogger(UserController.class);

    @Autowired private UserService userService;
    @Autowired private KakaoLoginService kakaoLoginService;
    @Autowired private EmailService emailService;
    @Autowired private CollectionService collectionService;
    @Autowired private LoginAttemptService loginAttemptService;
    @Autowired private ReviewService reviewService;
    @Autowired private WatchedService watchedService;
    @Autowired private WatchlistService watchlistService;
    @Autowired private ServletContext servletContext;

    private static final int MAX_FAIL = 5;
    private static final long LOCK_MINUTES = 10;

    // 이메일 인증 코드 유효시간 (5분)
    private static final long EMAIL_CODE_TTL_MS = 5L * 60L * 1000L;
    // 이메일 인증 코드와 함께 저장되는 발송 시각 세션 키
    private static final String EMAIL_CODE_SENT_AT = "emailCodeSentAt";

    /**
     * 세션에 저장된 emailCode가 발송된 지 5분이 지났는지 확인한다.
     * 만료된 경우 emailCode / emailCodeSentAt 을 세션에서 제거한다.
     * @return 만료되었거나 발송 시각이 없으면 true
     */
    private boolean isEmailCodeExpired(HttpSession session) {
        Object sentAtObj = session.getAttribute(EMAIL_CODE_SENT_AT);
        if (!(sentAtObj instanceof Long)) {
            // 발송 시각이 없다면 이전 버전에서 발급한 코드. 보수적으로 만료 처리.
            return true;
        }
        long elapsed = System.currentTimeMillis() - (Long) sentAtObj;
        if (elapsed > EMAIL_CODE_TTL_MS) {
            session.removeAttribute("emailCode");
            session.removeAttribute(EMAIL_CODE_SENT_AT);
            return true;
        }
        return false;
    }

    @RequestMapping(value = "/join", method = RequestMethod.GET)
    public String joinForm() {
        return "user/join";
    }

    @RequestMapping(value = "/join", method = RequestMethod.POST)
    public String joinProc(UserVO vo, HttpSession session, Model model) {
        String userId = InputValidator.trimToEmpty(vo.getUserId());
        String userEmail = InputValidator.trimToEmpty(vo.getUserEmail());
        String userName = InputValidator.trimToEmpty(vo.getUserName());

        vo.setUserId(userId);
        vo.setUserEmail(userEmail);
        vo.setUserName(userName);

        if (InputValidator.isBlank(userId, vo.getUserPw(), userEmail, userName)) {
            model.addAttribute("message", "모든 필수 항목을 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!InputValidator.isValidId(userId)) {
            model.addAttribute("message", "아이디는 영문과 숫자 4~20자로 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!InputValidator.isValidPw(vo.getUserPw())) {
            model.addAttribute("message", "비밀번호는 영문, 숫자, 특수문자(!@#$%^&*)를 포함한 8~20자로 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!InputValidator.isValidEmail(userEmail)) {
            model.addAttribute("message", "이메일 형식이 올바르지 않습니다.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!InputValidator.isValidNickname(userName)) {
            model.addAttribute("message", "닉네임은 한글, 영문, 숫자 2~10자로 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        boolean emailVerified = Boolean.TRUE.equals(session.getAttribute("emailVerified"));
        String verifiedEmail = InputValidator.trimToEmpty((String) session.getAttribute("verifiedEmail"));
        if (!emailVerified || !userEmail.equals(verifiedEmail)) {
            model.addAttribute("message", "이메일 인증을 완료해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        try {
            int result = userService.join(vo);
            if (result > 0) {
                session.removeAttribute("emailCode");
                session.removeAttribute("emailVerified");
                session.removeAttribute("verifiedEmail");
                session.removeAttribute("emailVerificationTarget");
                model.addAttribute("message", "회원가입이 완료되었습니다.");
                model.addAttribute("url", "user/login");
            } else {
                model.addAttribute("message", "회원가입에 실패했습니다.");
                model.addAttribute("url", "user/join");
            }
        } catch (Exception e) {
            log.warn("회원가입 실패 userId={}, email={}", userId, userEmail);
            model.addAttribute("message", "이미 사용중인 아이디 또는 이메일입니다.");
            model.addAttribute("url", "user/join");
        }
        return "common/message";
    }

    @RequestMapping(value = "/checkId", method = RequestMethod.POST)
    @ResponseBody
    public String checkId(String userId) {
        userId = InputValidator.trimToEmpty(userId);
        if (!InputValidator.isValidId(userId)) return "invalid";
        int cnt = userService.checkId(userId);
        return cnt > 0 ? "dup" : "ok";
    }

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginForm() {
        return "user/login";
    }

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String loginProc(String userId, String userPw, HttpServletRequest request,
                            Model model, RedirectAttributes ra) {
        userId = InputValidator.trimToEmpty(userId);
        String clientIp = resolveClientIp(request);
        if (InputValidator.isBlank(userId, userPw)) {
            model.addAttribute("message", "아이디와 비밀번호를 입력해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        if (loginAttemptService.isLocked(userId, clientIp)) {
            long remain = loginAttemptService.getRemainingLockMinutes(userId, clientIp);
            model.addAttribute("message", "로그인 시도 초과로 " + remain + "분간 잠겼습니다. 잠시 후 다시 시도해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        UserVO user = userService.login(userId, userPw);
        if (user == null) {
            LoginAttemptVO attempt = loginAttemptService.recordFailure(userId, clientIp);
            int failCnt = attempt == null ? 1 : attempt.getFailCount();
            int remain = Math.max(0, MAX_FAIL - failCnt);
            if (attempt != null && attempt.getLockUntil() != null
                    && attempt.getLockUntil().getTime() > System.currentTimeMillis()) {
                model.addAttribute("message", "로그인 " + MAX_FAIL + "회 실패로 " + LOCK_MINUTES + "분간 잠겼습니다.");
            } else {
                model.addAttribute("message", "아이디 또는 비밀번호가 올바르지 않습니다. (남은 시도: " + remain + "회)");
            }
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        loginAttemptService.clearFailureState(userId, clientIp);

        startLoginSession(request, user);

        return "redirect:/";
    }

    @RequestMapping(value = "/kakao/login", method = RequestMethod.GET)
    public String kakaoLogin(HttpServletRequest request, Model model) {
        try {
            clearPendingKakaoSession(request.getSession());
            String state = UUID.randomUUID().toString();
            request.getSession().setAttribute("kakaoOAuthState", state);
            return "redirect:" + kakaoLoginService.getAuthorizationUrl(request, state);
        } catch (Exception e) {
            log.warn("카카오 로그인 인증 URL 생성 실패", e);
            model.addAttribute("message", "카카오 로그인 설정을 확인해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }
    }

    @RequestMapping(value = "/kakao/callback", method = RequestMethod.GET)
    public String kakaoCallback(String code, String state, String error,
                                HttpServletRequest request, Model model, RedirectAttributes ra) {
        HttpSession session = request.getSession();
        String savedState = (String) session.getAttribute("kakaoOAuthState");
        session.removeAttribute("kakaoOAuthState");
        clearPendingKakaoSession(session);

        if (error != null || code == null || code.trim().isEmpty()
                || savedState == null || !savedState.equals(state)) {
            model.addAttribute("message", "카카오 로그인이 취소되었거나 올바르지 않은 요청입니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        try {
            KakaoProfileVO kakaoProfile = kakaoLoginService.getProfileWithCode(code, request);
            UserVO user = userService.getUserByKakaoId(kakaoProfile.getKakaoId());
            if (user != null) {
                startLoginSession(request, user);
                return "redirect:/";
            }

            // 아직 연결되지 않은 카카오 계정은 기존 계정 연결 화면에서 한 번 더 확인한다.
            session.setAttribute("pendingKakaoProfile", kakaoProfile);
            return "redirect:/user/kakao/link";
        } catch (Exception e) {
            log.warn("카카오 콜백 처리 실패", e);
            model.addAttribute("message", "카카오 로그인 처리 중 오류가 발생했습니다. " + getErrorMessage(e));
            model.addAttribute("url", "user/login");
            return "common/message";
        }
    }

    @RequestMapping(value = "/kakao/link", method = RequestMethod.GET)
    public String kakaoLinkForm(HttpSession session, Model model) {
        // 콜백에서 받은 카카오 프로필은 가입/연결이 끝날 때까지만 세션에 임시 보관한다.
        KakaoProfileVO kakaoProfile = (KakaoProfileVO) session.getAttribute("pendingKakaoProfile");
        if (kakaoProfile == null || kakaoProfile.getKakaoId() == null) {
            model.addAttribute("message", "카카오 인증 정보가 없습니다. 다시 시도해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        model.addAttribute("kakaoProfile", kakaoProfile);
        return "user/kakaoLink";
    }

    @RequestMapping(value = "/kakao/link", method = RequestMethod.POST)
    public String kakaoLinkProc(String userId, String userPw,
                                HttpServletRequest request, Model model, RedirectAttributes ra) {
        HttpSession session = request.getSession();
        // 기존 계정 비밀번호 검증에 성공해야 kakao_id를 연결한다.
        KakaoProfileVO kakaoProfile = (KakaoProfileVO) session.getAttribute("pendingKakaoProfile");
        if (kakaoProfile == null || kakaoProfile.getKakaoId() == null) {
            model.addAttribute("message", "카카오 인증 정보가 없습니다. 다시 시도해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        userId = InputValidator.trimToEmpty(userId);
        if (InputValidator.isBlank(userId, userPw)) {
            model.addAttribute("message", "연결할 기존 아이디와 비밀번호를 입력해주세요.");
            model.addAttribute("url", "user/kakao/link");
            return "common/message";
        }

        try {
            UserVO user = userService.linkKakaoAccount(userId, userPw, kakaoProfile.getKakaoId());
            if (user == null) {
                model.addAttribute("message", "아이디 또는 비밀번호가 올바르지 않습니다.");
                model.addAttribute("url", "user/kakao/link");
                return "common/message";
            }

            clearPendingKakaoSession(session);
            startLoginSession(request, user);
            return "redirect:/";
        } catch (Exception e) {
            log.warn("카카오 계정 연결 실패 userId=" + userId, e);
            model.addAttribute("message", "이미 다른 계정에 연결된 카카오 계정입니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }
    }

    @RequestMapping(value = "/kakao/join", method = RequestMethod.POST)
    public String kakaoJoinProc(HttpServletRequest request, Model model, RedirectAttributes ra) {
        HttpSession session = request.getSession();
        // 기존 계정이 없는 사용자만 내부용 kakao_ 아이디로 새 계정을 만든다.
        KakaoProfileVO kakaoProfile = (KakaoProfileVO) session.getAttribute("pendingKakaoProfile");
        if (kakaoProfile == null || kakaoProfile.getKakaoId() == null) {
            model.addAttribute("message", "카카오 인증 정보가 없습니다. 다시 시도해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        try {
            UserVO user = userService.joinKakaoUser(
                    kakaoProfile.getKakaoId(),
                    kakaoProfile.getNickname(),
                    kakaoProfile.getEmail()
            );
            clearPendingKakaoSession(session);
            startLoginSession(request, user);
            return "redirect:/";
        } catch (Exception e) {
            log.warn("카카오 회원가입 실패 kakaoId={}",
                    kakaoProfile == null ? null : kakaoProfile.getKakaoId(), e);
            model.addAttribute("message", "카카오 회원가입 처리 중 오류가 발생했습니다. " + getErrorMessage(e));
            model.addAttribute("url", "user/login");
            return "common/message";
        }
    }

    @RequestMapping("/logout")
    public String logout(HttpSession session, RedirectAttributes ra) {
        UserSessionRegistry.unregister(session);
        session.invalidate();
        return "redirect:/";
    }

    @RequestMapping(value = "/withdraw", method = RequestMethod.POST)
    public String withdraw(String currentPw, HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        UserVO currentUser = userService.getUser(loginUser.getUserNo());
        if (currentUser == null) {
            UserSessionRegistry.unregister(session);
            session.invalidate();
            model.addAttribute("message", "이미 탈퇴 처리되었거나 존재하지 않는 계정입니다.");
            model.addAttribute("url", "");
            return "common/message";
        }

        if (requiresCurrentPassword(currentUser)) {
            currentPw = InputValidator.trimToEmpty(currentPw);
            if (currentPw.isEmpty()) {
                model.addAttribute("message", "회원 탈퇴를 위해 현재 비밀번호를 입력해주세요.");
                model.addAttribute("url", "user/mypage");
                return "common/message";
            }

            if (userService.login(currentUser.getUserId(), currentPw) == null) {
                model.addAttribute("message", "현재 비밀번호가 올바르지 않습니다.");
                model.addAttribute("url", "user/mypage");
                return "common/message";
            }
        }

        try {
            userService.withdrawUser(currentUser.getUserNo());
            UserSessionRegistry.invalidateUserSessions(currentUser.getUserNo());
            model.addAttribute("message", "회원 탈퇴가 완료되었습니다.");
            model.addAttribute("url", "");
        } catch (Exception e) {
            model.addAttribute("message", "회원 탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해주세요.");
            model.addAttribute("url", "user/mypage");
        }
        return "common/message";
    }

    @RequestMapping("/mypage")
    public String mypage(HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        List<ReviewVO> reviewList = reviewService.getReviewsByUserNo(loginUser.getUserNo());
        List<WatchlistVO> watchList = watchlistService.getWatchlistByUserNo(loginUser.getUserNo());
        List<WatchedVO> watchedList = watchedService.getMyWatched(loginUser.getUserId());
        List<CollectionVO> collectionList = collectionService.getMyCollections(loginUser.getUserId());

        if (reviewList == null) {
            reviewList = Collections.emptyList();
        }
        if (watchList == null) {
            watchList = Collections.emptyList();
        }
        if (watchedList == null) {
            watchedList = Collections.emptyList();
        }
        if (collectionList == null) {
            collectionList = Collections.emptyList();
        }

        if (!reviewList.isEmpty()) {
            double sum = 0;
            for (ReviewVO r : reviewList) {
                sum += r.getRating();
            }
            model.addAttribute("avgRating", Math.round((sum / reviewList.size()) * 10) / 10.0);
        }
        model.addAttribute("user", loginUser);
        model.addAttribute("reviewList", reviewList);
        model.addAttribute("watchList", watchList);
        model.addAttribute("watchedList", watchedList);
        model.addAttribute("collectionCount", collectionList.size());
        return "user/mypage";
    }

    @RequestMapping(value = "/sendEmail", method = RequestMethod.POST)
    @ResponseBody
    public String sendEmail(String userEmail, HttpSession session) {
        userEmail = InputValidator.trimToEmpty(userEmail);
        if (!InputValidator.isValidEmail(userEmail)) return "fail";
        String code = emailService.sendAuthMail(userEmail);
        if (code != null) {
            session.setAttribute("emailCode", code);
            session.setAttribute(EMAIL_CODE_SENT_AT, System.currentTimeMillis());
            session.setAttribute("emailVerificationTarget", userEmail);
            session.removeAttribute("emailVerified");
            session.removeAttribute("verifiedEmail");
            return "ok";
        }
        return "fail";
    }

    @RequestMapping(value = "/checkEmailCode", method = RequestMethod.POST)
    @ResponseBody
    public String checkEmailCode(String code, HttpSession session) {
        code = InputValidator.trimToEmpty(code);
        if (!InputValidator.isValidAuthCode(code)) return "fail";
        if (isEmailCodeExpired(session)) return "expired";
        String savedCode = (String) session.getAttribute("emailCode");
        if (savedCode != null && savedCode.equals(code)) {
            session.setAttribute("emailVerified", true);
            if (session.getAttribute("findPwUserId") != null) {
                session.setAttribute("findPwVerified", true);
            } else {
                String verificationTarget = InputValidator.trimToEmpty((String) session.getAttribute("emailVerificationTarget"));
                if (!verificationTarget.isEmpty()) {
                    session.setAttribute("verifiedEmail", verificationTarget);
                }
            }
            return "ok";
        }
        return "fail";
    }

    @RequestMapping(value = "/checkEmail", method = RequestMethod.POST)
    @ResponseBody
    public String checkEmail(String userEmail) {
        userEmail = InputValidator.trimToEmpty(userEmail);
        if (!InputValidator.isValidEmail(userEmail)) return "invalid";
        return userService.checkEmail(userEmail) > 0 ? "dup" : "ok";
    }

    @RequestMapping(value = "/edit", method = RequestMethod.GET)
    public String editForm(HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }
        model.addAttribute("user", loginUser);
        return "user/edit";
    }

    @RequestMapping(value = "/edit", method = RequestMethod.POST)
    public String editProc(UserVO vo, HttpSession session, MultipartFile imgFile, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        String userName = InputValidator.trimToEmpty(vo.getUserName());
        String userEmail = InputValidator.trimToEmpty(vo.getUserEmail());
        String userBio = InputValidator.trimToEmpty(vo.getUserBio());
        String userZipcode = InputValidator.trimToEmpty(vo.getUserZipcode());
        String userAddr1 = InputValidator.trimToEmpty(vo.getUserAddr1());
        String userAddr2 = InputValidator.trimToEmpty(vo.getUserAddr2());

        if (!InputValidator.isValidNickname(userName)) {
            model.addAttribute("message", "닉네임은 한글, 영문, 숫자 2~10자로 입력해주세요.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        if (!InputValidator.isValidEmail(userEmail)) {
            model.addAttribute("message", "이메일 형식이 올바르지 않습니다.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        if (!userBio.isEmpty() && !InputValidator.isValidLength(userBio, 1, 300)) {
            model.addAttribute("message", "자기소개는 300자 이하로 입력해주세요.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        vo.setUserNo(loginUser.getUserNo());
        vo.setUserName(userName);
        vo.setUserEmail(userEmail);
        vo.setUserBio(userBio);
        vo.setUserZipcode(userZipcode);
        vo.setUserAddr1(userAddr1);
        vo.setUserAddr2(userAddr2);
        if (imgFile != null && !imgFile.isEmpty()) {
            String fileName = saveFile(imgFile);
            if (fileName == null) {
                model.addAttribute("message", "프로필 이미지는 jpg, jpeg, png, gif 형식의 10MB 이하 실제 이미지 파일만 업로드해주세요.");
                model.addAttribute("url", "user/edit");
                return "common/message";
            }
            vo.setUserImg(fileName);
            if (loginUser.getUserImg() != null && !"default.png".equals(loginUser.getUserImg())) {
                new File(servletContext.getRealPath("/resources/data/") + "/" + loginUser.getUserImg()).delete();
            }
        } else {
            vo.setUserImg(loginUser.getUserImg());
        }

        int result = userService.updateUser(vo);
        if (result > 0) {
            session.setAttribute("loginUser", userService.getUser(loginUser.getUserNo()));
            model.addAttribute("message", "프로필이 수정되었습니다.");
            model.addAttribute("url", "user/mypage");
        } else {
            model.addAttribute("message", "수정에 실패했습니다.");
            model.addAttribute("url", "user/edit");
        }
        return "common/message";
    }

    @RequestMapping(value = "/changePw", method = RequestMethod.POST)
    public String changePw(String currentPw, String newPw, HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        if (InputValidator.isBlank(currentPw, newPw)) {
            model.addAttribute("message", "현재 비밀번호와 새 비밀번호를 모두 입력해주세요.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        if (!InputValidator.isValidPw(newPw)) {
            model.addAttribute("message", "새 비밀번호는 영문, 숫자, 특수문자(!@#$%^&*)를 포함한 8~20자로 입력해주세요.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        if (currentPw.equals(newPw)) {
            model.addAttribute("message", "새 비밀번호는 현재 비밀번호와 다르게 설정해주세요.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        if (userService.login(loginUser.getUserId(), currentPw) == null) {
            model.addAttribute("message", "현재 비밀번호가 올바르지 않습니다.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        UserVO vo = new UserVO();
        vo.setUserNo(loginUser.getUserNo());
        vo.setUserPw(DigestUtils.sha256Hex(newPw));
        userService.updatePw(vo);
        UserSessionRegistry.invalidateUserSessions(loginUser.getUserNo());
        model.addAttribute("message", "비밀번호가 변경되었습니다. 다시 로그인해주세요.");
        model.addAttribute("url", "user/login");
        return "common/message";
    }

    @RequestMapping(value = "/findId", method = RequestMethod.GET)
    public String findIdForm() {
        return "user/findId";
    }

    @RequestMapping(value = "/findId/sendCode", method = RequestMethod.POST)
    @ResponseBody
    public String findIdSendCode(String userEmail, HttpSession session) {
        userEmail = InputValidator.trimToEmpty(userEmail);
        if (!InputValidator.isValidEmail(userEmail)) return "fail";
        UserVO user = userService.getUserByEmail(userEmail);
        if (user == null) return "notFound";
        String code = emailService.sendAuthMail(userEmail);
        if (code == null) return "fail";
        session.setAttribute("emailCode", code);
        session.setAttribute(EMAIL_CODE_SENT_AT, System.currentTimeMillis());
        session.setAttribute("findIdEmail", userEmail);
        return "ok";
    }

    @RequestMapping(value = "/findId/checkCode", method = RequestMethod.POST)
    @ResponseBody
    public String findIdCheckCode(String code, HttpSession session) {
        code = InputValidator.trimToEmpty(code);
        if (!InputValidator.isValidAuthCode(code)) return "fail";
        if (isEmailCodeExpired(session)) return "expired";
        String savedCode = (String) session.getAttribute("emailCode");
        if (savedCode == null || !savedCode.equals(code)) return "fail";

        String email = (String) session.getAttribute("findIdEmail");
        UserVO user = userService.getUserByEmail(email);
        if (user == null) return "fail";

        session.removeAttribute("emailCode");
        session.removeAttribute(EMAIL_CODE_SENT_AT);
        session.removeAttribute("findIdEmail");

        String userId = user.getUserId();
        if (userId == null || userId.isEmpty()) return "fail";
        if (userId.length() == 1) return userId;
        if (userId.length() == 2) return userId.charAt(0) + "*";
        return userId.substring(0, 2) + "*".repeat(userId.length() - 2);
    }

    @RequestMapping(value = "/findPw", method = RequestMethod.GET)
    public String findPwForm() {
        return "user/findPw";
    }

    @RequestMapping(value = "/findPw/sendCode", method = RequestMethod.POST)
    @ResponseBody
    public String findPwSendCode(String userId, String userEmail, HttpSession session) {
        userId = InputValidator.trimToEmpty(userId);
        userEmail = InputValidator.trimToEmpty(userEmail);
        if (!InputValidator.isValidId(userId) || !InputValidator.isValidEmail(userEmail)) return "fail";
        UserVO user = userService.getUserByIdAndEmail(userId, userEmail);
        if (user == null) return "notFound";
        String code = emailService.sendAuthMail(userEmail);
        if (code == null) return "fail";
        session.setAttribute("emailCode", code);
        session.setAttribute(EMAIL_CODE_SENT_AT, System.currentTimeMillis());
        session.setAttribute("findPwUserId", userId);
        session.removeAttribute("findPwVerified");
        return "ok";
    }

    @RequestMapping(value = "/findPw/changePw", method = RequestMethod.POST)
    @ResponseBody
    public String findPwChange(String userId, String newPw, HttpSession session) {
        userId = InputValidator.trimToEmpty(userId);
        String sessionUserId = (String) session.getAttribute("findPwUserId");
        Boolean verified = (Boolean) session.getAttribute("findPwVerified");
        if (sessionUserId == null || !sessionUserId.equals(userId) || !Boolean.TRUE.equals(verified)) return "fail";
        if (!InputValidator.isValidPw(newPw)) return "fail";

        UserVO vo = userService.getUserByUserId(userId);
        if (vo == null) return "fail";

        vo.setUserPw(DigestUtils.sha256Hex(newPw));
        userService.updatePw(vo);
        session.removeAttribute("emailCode");
        session.removeAttribute(EMAIL_CODE_SENT_AT);
        session.removeAttribute("findPwUserId");
        session.removeAttribute("findPwVerified");
        return "ok";
    }

    // ──────────────────────────── private helpers ────────────────────────────

    /**
     * 로그인 성공 시 세션에 사용자 정보를 저장하고 중복 로그인을 방지한다.
     * 동일 계정의 다른 기기 세션은 강제 무효화한다.
     */
    private void startLoginSession(HttpServletRequest request, UserVO user) {
        HttpSession session = request.getSession();
        session.setAttribute("loginUser", user);
        UserSessionRegistry.invalidateOtherUserSessions(user.getUserNo(), session);
        UserSessionRegistry.register(user, session);
    }

    /**
     * 카카오 OAuth 콜백 중 임시 보관한 프로필 세션을 제거한다.
     */
    private void clearPendingKakaoSession(HttpSession session) {
        session.removeAttribute("pendingKakaoProfile");
    }

    /**
     * 카카오 계정 연동 사용자처럼 비밀번호가 없는 경우 false를 반환한다.
     * userPw 컬럼이 비어 있으면 현재 비밀번호 확인 단계를 건너뛴다.
     */
    private boolean requiresCurrentPassword(UserVO user) {
        if (user == null) return false;
        String pw = user.getUserPw();
        return pw != null && !pw.isEmpty();
    }

    /**
     * 예외에서 간결한 사용자 메시지를 추출한다.
     */
    private String getErrorMessage(Exception e) {
        if (e == null) return "";
        String msg = e.getMessage();
        return (msg != null && !msg.isEmpty()) ? msg : e.getClass().getSimpleName();
    }

    /**
     * 프로필 이미지를 서버 디스크에 저장하고 파일명을 반환한다.
     * 확장자·크기·실제 이미지 여부를 검증하며, 실패 시 null을 반환한다.
     */
    private String saveFile(MultipartFile imgFile) {
        if (imgFile == null || imgFile.isEmpty()) return null;

        String originalName = imgFile.getOriginalFilename();
        if (originalName == null || !originalName.contains(".")) return null;

        String ext = originalName.substring(originalName.lastIndexOf('.') + 1).toLowerCase();
        if (!ext.matches("jpg|jpeg|png|gif")) return null;

        // 10 MB 제한
        if (imgFile.getSize() > 10L * 1024 * 1024) return null;

        // 실제 이미지 파일인지 확인 (MIME 스푸핑 방지)
        try {
            BufferedImage img = ImageIO.read(new ByteArrayInputStream(imgFile.getBytes()));
            if (img == null) return null;
        } catch (Exception e) {
            log.warn("이미지 검증 실패: {}", e.getMessage());
            return null;
        }

        String savePath = servletContext.getRealPath("/resources/data/");
        File dir = new File(savePath);
        if (!dir.exists()) dir.mkdirs();

        String fileName = UUID.randomUUID().toString() + "." + ext;
        try {
            imgFile.transferTo(new File(savePath + File.separator + fileName));
            return fileName;
        } catch (Exception e) {
            log.warn("파일 저장 실패: {}", e.getMessage());
            return null;
        }
    }

    private String resolveClientIp(HttpServletRequest request) {
        if (request == null) return "";

        String[] headerNames = {
                "X-Forwarded-For",
                "X-Real-IP",
                "Proxy-Client-IP",
                "WL-Proxy-Client-IP"
        };

        for (String header : headerNames) {
            String ip = request.getHeader(header);
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                return ip.split(",")[0].trim();
            }
        }

        return request.getRemoteAddr();
    }

}
