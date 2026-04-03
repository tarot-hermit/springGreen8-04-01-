package com.spring.springGreen8.controller;

import java.io.File;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.spring.springGreen8.service.EmailService;
import com.spring.springGreen8.service.ReviewService;
import com.spring.springGreen8.service.UserService;
import com.spring.springGreen8.service.WatchlistService;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;
import com.spring.springGreen8.vo.WatchlistVO;

@Controller
@RequestMapping("/user")
public class UserController {

    @Autowired private UserService userService;
    @Autowired private EmailService emailService;
    @Autowired private ReviewService reviewService;
    @Autowired private WatchlistService watchlistService;
    @Autowired private ServletContext servletContext;

    private static final ConcurrentHashMap<String, Integer> failMap = new ConcurrentHashMap<>();
    private static final ConcurrentHashMap<String, Long> lockMap = new ConcurrentHashMap<>();
    private static final int MAX_FAIL = 5;
    private static final long LOCK_MINUTES = 10;

    @RequestMapping(value = "/join", method = RequestMethod.GET)
    public String joinForm() {
        return "user/join";
    }

    @RequestMapping(value = "/join", method = RequestMethod.POST)
    public String joinProc(UserVO vo, Model model) {
        if (isBlank(vo.getUserId(), vo.getUserPw(), vo.getUserEmail(), vo.getUserName())) {
            model.addAttribute("message", "모든 필수 항목을 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!vo.getUserId().matches("^[a-zA-Z0-9]{4,20}$")) {
            model.addAttribute("message", "아이디는 영문과 숫자 4~20자로 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!vo.getUserPw().matches("^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{8,20}$")) {
            model.addAttribute("message", "비밀번호는 영문, 숫자, 특수문자(!@#$%^&*)를 포함한 8~20자로 입력해주세요.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        if (!vo.getUserEmail().matches("^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$")) {
            model.addAttribute("message", "이메일 형식이 올바르지 않습니다.");
            model.addAttribute("url", "user/join");
            return "common/message";
        }

        try {
            int result = userService.join(vo);
            if (result > 0) {
                model.addAttribute("message", "회원가입이 완료되었습니다.");
                model.addAttribute("url", "user/login");
            } else {
                model.addAttribute("message", "회원가입에 실패했습니다.");
                model.addAttribute("url", "user/join");
            }
        } catch (Exception e) {
            model.addAttribute("message", "이미 사용중인 아이디 또는 이메일입니다.");
            model.addAttribute("url", "user/join");
        }
        return "common/message";
    }

    @RequestMapping(value = "/checkId", method = RequestMethod.POST)
    @ResponseBody
    public String checkId(String userId) {
        int cnt = userService.checkId(userId);
        return cnt > 0 ? "dup" : "ok";
    }

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginForm() {
        return "user/login";
    }

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String loginProc(String userId, String userPw, HttpServletRequest request, Model model) {
        if (isBlank(userId, userPw)) {
            model.addAttribute("message", "아이디와 비밀번호를 입력해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        if (isLocked(userId)) {
            long remain = getRemainingLockMinutes(userId);
            model.addAttribute("message", "로그인 시도 초과로 " + remain + "분간 잠겼습니다. 잠시 후 다시 시도해주세요.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        UserVO user = userService.login(userId, userPw);
        if (user == null) {
            int failCnt = failMap.merge(userId, 1, Integer::sum);
            int remain = MAX_FAIL - failCnt;
            if (failCnt >= MAX_FAIL) {
                lockMap.put(userId, System.currentTimeMillis());
                failMap.put(userId, 0);
                model.addAttribute("message", "로그인 " + MAX_FAIL + "회 실패로 " + LOCK_MINUTES + "분간 잠겼습니다.");
            } else {
                model.addAttribute("message", "아이디 또는 비밀번호가 올바르지 않습니다. (남은 시도: " + remain + "회)");
            }
            model.addAttribute("url", "user/login");
            return "common/message";
        }

        failMap.remove(userId);
        lockMap.remove(userId);

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) oldSession.invalidate();
        HttpSession newSession = request.getSession(true);
        newSession.setAttribute("loginUser", user);

        return "redirect:/";
    }

    @RequestMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
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
        return "user/mypage";
    }

    @RequestMapping(value = "/sendEmail", method = RequestMethod.POST)
    @ResponseBody
    public String sendEmail(String userEmail, HttpSession session) {
        String code = emailService.sendAuthMail(userEmail);
        if (code != null) {
            session.setAttribute("emailCode", code);
            return "ok";
        }
        return "fail";
    }

    @RequestMapping(value = "/checkEmailCode", method = RequestMethod.POST)
    @ResponseBody
    public String checkEmailCode(String code, HttpSession session) {
        String savedCode = (String) session.getAttribute("emailCode");
        if (savedCode != null && savedCode.equals(code)) {
            session.setAttribute("emailVerified", true);
            if (session.getAttribute("findPwUserId") != null) {
                session.setAttribute("findPwVerified", true);
            }
            return "ok";
        }
        return "fail";
    }

    @RequestMapping(value = "/checkEmail", method = RequestMethod.POST)
    @ResponseBody
    public String checkEmail(String userEmail) {
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

        vo.setUserNo(loginUser.getUserNo());
        if (imgFile != null && !imgFile.isEmpty()) {
            String fileName = saveFile(imgFile);
            if (fileName != null) {
                vo.setUserImg(fileName);
                if (loginUser.getUserImg() != null && !"default.png".equals(loginUser.getUserImg())) {
                    new File(servletContext.getRealPath("/resources/data/") + "/" + loginUser.getUserImg()).delete();
                }
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
        if (userService.login(loginUser.getUserId(), currentPw) == null) {
            model.addAttribute("message", "현재 비밀번호가 올바르지 않습니다.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }

        UserVO vo = new UserVO();
        vo.setUserNo(loginUser.getUserNo());
        vo.setUserPw(DigestUtils.sha256Hex(newPw));
        userService.updatePw(vo);
        session.invalidate();
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
        UserVO user = userService.getUserByEmail(userEmail);
        if (user == null) return "notFound";
        String code = emailService.sendAuthMail(userEmail);
        if (code == null) return "fail";
        session.setAttribute("emailCode", code);
        session.setAttribute("findIdEmail", userEmail);
        return "ok";
    }

    @RequestMapping(value = "/findId/checkCode", method = RequestMethod.POST)
    @ResponseBody
    public String findIdCheckCode(String code, HttpSession session) {
        String savedCode = (String) session.getAttribute("emailCode");
        if (savedCode == null || !savedCode.equals(code)) return "fail";

        String email = (String) session.getAttribute("findIdEmail");
        UserVO user = userService.getUserByEmail(email);
        if (user == null) return "fail";

        session.removeAttribute("emailCode");
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
        UserVO user = userService.getUserByIdAndEmail(userId, userEmail);
        if (user == null) return "notFound";
        String code = emailService.sendAuthMail(userEmail);
        if (code == null) return "fail";
        session.setAttribute("emailCode", code);
        session.setAttribute("findPwUserId", userId);
        session.removeAttribute("findPwVerified");
        return "ok";
    }

    @RequestMapping(value = "/findPw/changePw", method = RequestMethod.POST)
    @ResponseBody
    public String findPwChange(String userId, String newPw, HttpSession session) {
        String sessionUserId = (String) session.getAttribute("findPwUserId");
        Boolean verified = (Boolean) session.getAttribute("findPwVerified");
        if (sessionUserId == null || !sessionUserId.equals(userId) || !Boolean.TRUE.equals(verified)) return "fail";

        UserVO vo = userService.getUserByUserId(userId);
        if (vo == null) return "fail";

        vo.setUserPw(DigestUtils.sha256Hex(newPw));
        userService.updatePw(vo);
        session.removeAttribute("emailCode");
        session.removeAttribute("findPwUserId");
        session.removeAttribute("findPwVerified");
        return "ok";
    }

    private boolean isLocked(String userId) {
        Long lockTime = lockMap.get(userId);
        if (lockTime == null) return false;
        long elapsed = (System.currentTimeMillis() - lockTime) / 60000;
        if (elapsed >= LOCK_MINUTES) {
            lockMap.remove(userId);
            return false;
        }
        return true;
    }

    private long getRemainingLockMinutes(String userId) {
        Long lockTime = lockMap.get(userId);
        if (lockTime == null) return 0;
        return Math.max(0, LOCK_MINUTES - (System.currentTimeMillis() - lockTime) / 60000);
    }

    private boolean isBlank(String... values) {
        for (String v : values) {
            if (v == null || v.trim().isEmpty()) return true;
        }
        return false;
    }

    private String saveFile(MultipartFile file) {
        try {
            String uploadPath = servletContext.getRealPath("/resources/data/");
            if (uploadPath == null) return null;

            File dir = new File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            String originalName = file.getOriginalFilename();
            if (originalName == null || originalName.trim().isEmpty()) return null;

            int dotIndex = originalName.lastIndexOf('.');
            if (dotIndex < 0 || dotIndex == originalName.length() - 1) return null;

            String ext = originalName.substring(dotIndex).toLowerCase();
            if (!ext.matches("\\.(png|jpg|jpeg|gif|webp)$")) return null;

            String fileName = System.currentTimeMillis() + ext;
            file.transferTo(new File(uploadPath + "/" + fileName));
            return fileName;
        } catch (Exception e) {
            return null;
        }
    }
}
