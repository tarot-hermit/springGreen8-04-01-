package com.spring.springGreen8.controller;

import java.util.List;

import javax.servlet.ServletContext;
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

    @Autowired
    private UserService userService;

    @Autowired
    private EmailService emailService;
    
    @Autowired
    private ReviewService reviewService;

    @Autowired
    private WatchlistService watchlistService;
    
    @Autowired
    private ServletContext servletContext;

    // 회원가입 폼
    @RequestMapping(value = "/join", method = RequestMethod.GET)
    public String joinForm() {
        return "user/join";
    }

    // 회원가입 처리
    @RequestMapping(value = "/join", method = RequestMethod.POST)
    public String joinProc(UserVO vo, Model model) {
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

    // 아이디 중복 체크 (Ajax)
    @RequestMapping(value = "/checkId", method = RequestMethod.POST)
    @ResponseBody
    public String checkId(String userId) {
        int cnt = userService.checkId(userId);
        return cnt > 0 ? "dup" : "ok";
    }

    // 로그인 폼
    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String loginForm() {
        return "user/login";
    }

    // 로그인 처리
    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String loginProc(String userId, String userPw,
                            HttpSession session, Model model) {
        UserVO user = userService.login(userId, userPw);
        if (user != null) {
            session.setAttribute("loginUser", user);
            return "redirect:/";
        } else {
            model.addAttribute("message", "아이디 또는 비밀번호가 틀렸습니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }
    }

    // 로그아웃
    @RequestMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    // 마이페이지
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
            double avg = Math.round((sum / reviewList.size()) * 10) / 10.0;
            model.addAttribute("avgRating", avg);
        }

        model.addAttribute("user", loginUser);
        model.addAttribute("reviewList", reviewList);
        model.addAttribute("watchList", watchList);
        return "user/mypage";
    }

    // 이메일 인증코드 발송 (Ajax)
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

    // 이메일 인증코드 확인 (Ajax)
    @RequestMapping(value = "/checkEmailCode", method = RequestMethod.POST)
    @ResponseBody
    public String checkEmailCode(String code, HttpSession session) {
        String savedCode = (String) session.getAttribute("emailCode");
        if (savedCode != null && savedCode.equals(code)) {
            session.setAttribute("emailVerified", true);
            return "ok";
        }
        return "fail";
    }
    
    @RequestMapping(value = "/checkEmail", method = RequestMethod.POST)
    @ResponseBody
    public String checkEmail(String userEmail) {
        int cnt = userService.checkEmail(userEmail);
        return cnt > 0 ? "dup" : "ok";
    }
    
 // 프로필 수정 폼
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

    // 프로필 수정 처리
    @RequestMapping(value = "/edit", method = RequestMethod.POST)
    public String editProc(UserVO vo, HttpSession session,
                           MultipartFile imgFile, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }
        vo.setUserNo(loginUser.getUserNo());

        // 이미지 업로드 처리
        if (imgFile != null && !imgFile.isEmpty()) {
            String fileName = saveFile(imgFile);
            if (fileName != null) {
                vo.setUserImg(fileName);
                // 기존 이미지 삭제 (default.png 제외)
                if (!loginUser.getUserImg().equals("default.png")) {
                	String oldPath = servletContext.getRealPath("/resources/data/")
                            + "/" + loginUser.getUserImg();
                    new java.io.File(oldPath).delete();
                }
            }
        } else {
            vo.setUserImg(loginUser.getUserImg());
        }

        int result = userService.updateUser(vo);
        if (result > 0) {
            // 세션 정보 업데이트
            UserVO updatedUser = userService.getUser(loginUser.getUserNo());
            session.setAttribute("loginUser", updatedUser);
            model.addAttribute("message", "프로필이 수정되었습니다.");
            model.addAttribute("url", "user/mypage");
        } else {
            model.addAttribute("message", "수정에 실패했습니다.");
            model.addAttribute("url", "user/edit");
        }
        return "common/message";
    }

    // 비밀번호 변경
    @RequestMapping(value = "/changePw", method = RequestMethod.POST)
    public String changePw(String currentPw, String newPw,
                           HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            model.addAttribute("message", "로그인이 필요합니다.");
            model.addAttribute("url", "user/login");
            return "common/message";
        }
        // 현재 비밀번호 확인
        UserVO user = userService.login(loginUser.getUserId(), currentPw);
        if (user == null) {
            model.addAttribute("message", "현재 비밀번호가 틀렸습니다.");
            model.addAttribute("url", "user/edit");
            return "common/message";
        }
        // 새 비밀번호 저장
        UserVO vo = new UserVO();
        vo.setUserNo(loginUser.getUserNo());
        vo.setUserPw(DigestUtils.sha256Hex(newPw));
        userService.updatePw(vo);
        model.addAttribute("message", "비밀번호가 변경되었습니다. 다시 로그인해주세요.");
        model.addAttribute("url", "user/login");
        session.invalidate();
        return "common/message";
    }

    // 파일 저장 유틸
    private String saveFile(MultipartFile file) {
        try {
            // 실제 프로젝트 내부 경로
            String uploadPath = servletContext.getRealPath("/resources/data/");
            java.io.File dir = new java.io.File(uploadPath);
            if (!dir.exists()) dir.mkdirs();

            String originalName = file.getOriginalFilename();
            String ext = originalName.substring(originalName.lastIndexOf("."));
            String fileName = System.currentTimeMillis() + ext;

            file.transferTo(new java.io.File(uploadPath + "/" + fileName));
            return fileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    // 아이디 찾기 폼
    @RequestMapping(value = "/findId" , method = RequestMethod.GET)
    public String findIdForm() {
    	return "user/findId";
    }
    // 아이디 찾기 - 인증코드 발송
    @RequestMapping(value = "/findId/sendCode" , method= RequestMethod.POST)
    @ResponseBody
    public String findIdSendCode(String userEmail, HttpSession session) {
    	// 이메일로 회원 조회
    	UserVO user = userService.getUserByEmail(userEmail);
    	if (user == null) return "notFound";
    	
    	// 인증 코드 발송
    	String code = emailService.sendAuthMail(userEmail);
    	if (code == null) return "fail";
    	
    	session.setAttribute("emailCode", code);
    	session.setAttribute("findIdEmail", userEmail);
    	return "ok";
    }
    
    @RequestMapping(value = "/findId/checkCode", method = RequestMethod.POST)
    @ResponseBody
    public String findIdCheckCode(String code , HttpSession session) {
    	String savedCode = (String) session.getAttribute("emailCode");
    	if (savedCode == null || !savedCode.equals(code)) return "fail";
    	
    	String email = (String) session.getAttribute("findIdEmail");
    	UserVO user = userService.getUserByEmail(email);
    	if (user == null) return "fail";
    	
    	// 세션 정리
    	session.removeAttribute("emailCode");
    	session.removeAttribute("findIdEmail");
    	
    	// 아이디 마스킹 (앞 2자리만 보이고 나머지 * 처리)
    	String userId = user.getUserId();
    	String masked = userId.substring(0,2)
    					+ "*".repeat(userId.length() - 2);
    	return masked;
    }
    
 // 비밀번호 찾기 폼
    @RequestMapping(value = "/findPw", method = RequestMethod.GET)
    public String findPwForm() {
        return "user/findPw";
    }

    // 인증코드 발송
    @RequestMapping(value = "/findPw/sendCode", method = RequestMethod.POST)
    @ResponseBody
    public String findPwSendCode(String userId, String userEmail,
                                  HttpSession session) {
        // 아이디 + 이메일 일치 확인
        UserVO user = userService.getUserByIdAndEmail(userId, userEmail);
        if (user == null) return "notFound";

        // 인증코드 발송
        String code = emailService.sendAuthMail(userEmail);
        if (code == null) return "fail";

        session.setAttribute("emailCode", code);
        session.setAttribute("findPwUserId", userId);
        return "ok";
    }

    // 비밀번호 변경
    @RequestMapping(value = "/findPw/changePw", method = RequestMethod.POST)
    @ResponseBody
    public String findPwChange(String userId, String newPw,
                                HttpSession session) {
        String sessionUserId = (String) session.getAttribute("findPwUserId");
        if (sessionUserId == null || !sessionUserId.equals(userId)) return "fail";

        UserVO vo = userService.getUserByUserId(userId);
        if (vo == null) return "fail";

        vo.setUserPw(DigestUtils.sha256Hex(newPw));
        userService.updatePw(vo);

        session.removeAttribute("emailCode");
        session.removeAttribute("findPwUserId");
        return "ok";
    }
    
}