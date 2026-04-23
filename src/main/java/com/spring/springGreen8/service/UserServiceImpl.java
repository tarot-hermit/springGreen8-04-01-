package com.spring.springGreen8.service;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.CollectionDAO;
import com.spring.springGreen8.dao.CommentDAO;
import com.spring.springGreen8.dao.LoginAttemptDAO;
import com.spring.springGreen8.dao.NotificationDAO;
import com.spring.springGreen8.dao.ReportDAO;
import com.spring.springGreen8.dao.ReviewDAO;
import com.spring.springGreen8.dao.SearchHistoryDAO;
import com.spring.springGreen8.dao.UserDAO;
import com.spring.springGreen8.dao.WatchedDAO;
import com.spring.springGreen8.dao.WatchlistDAO;
import com.spring.springGreen8.util.InputValidator;
import com.spring.springGreen8.vo.UserVO;

@Service
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

    private static final String ANONYMOUS_USER_ID = "__deleted_user__";
    private static final String ANONYMOUS_USER_NAME = "\uD0C8\uD1F4\uD55C \uC0AC\uC6A9\uC790";
    private static final int USER_ID_MAX_LENGTH = 50;

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private ReviewDAO reviewDAO;

    @Autowired
    private CommentDAO commentDAO;

    @Autowired
    private WatchlistDAO watchlistDAO;

    @Autowired
    private WatchedDAO watchedDAO;

    @Autowired
    private CollectionDAO collectionDAO;

    @Autowired
    private SearchHistoryDAO searchHistoryDAO;

    @Autowired
    private NotificationDAO notificationDAO;

    @Autowired
    private ReportDAO reportDAO;

    @Autowired
    private LoginAttemptDAO loginAttemptDAO;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int join(UserVO vo) {
        String userId = InputValidator.trimToEmpty(vo.getUserId());
        if (userDAO.checkId(userId) > 0) {
            throw new IllegalStateException("User id is unavailable.");
        }

        vo.setUserId(userId);
        vo.setUserPw(DigestUtils.sha256Hex(vo.getUserPw()));
        return userDAO.insertUser(vo);
    }

    @Override
    public int checkId(String userId) {
        return userDAO.checkId(userId);
    }

    @Override
    public UserVO login(String userId, String userPw) {
        UserVO user = userDAO.selectUserById(userId);
        if (user == null) {
            return null;
        }

        String encPw = DigestUtils.sha256Hex(userPw);
        return encPw.equals(user.getUserPw()) ? user : null;
    }

    @Override
    public UserVO getUser(int userNo) {
        return userDAO.selectUserByNo(userNo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateUser(UserVO vo) {
        return userDAO.updateUser(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateUserImg(UserVO vo) {
        return userDAO.updateUserImg(vo);
    }

    @Override
    public int checkEmail(String userEmail) {
        return userDAO.checkEmail(userEmail);
    }

    @Override
    public UserVO getUserByIdAndEmail(String userId, String userEmail) {
        return userDAO.selectUserByIdAndEmail(userId, userEmail);
    }

    @Override
    public UserVO getUserByUserId(String userId) {
        return userDAO.selectUserById(userId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updatePw(UserVO vo) {
        return userDAO.updatePw(vo);
    }

    @Override
    public UserVO getUserByEmail(String userEmail) {
        return userDAO.selectUserByEmail(userEmail);
    }

    @Override
    public UserVO getUserByKakaoId(String kakaoId) {
        if (kakaoId == null || kakaoId.trim().isEmpty()) {
            return null;
        }
        return userDAO.selectUserByKakaoId(kakaoId.trim());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserVO linkKakaoAccount(String userId, String userPw, String kakaoId) {
        UserVO user = login(userId, userPw);
        if (user == null || kakaoId == null || kakaoId.trim().isEmpty()) {
            return null;
        }

        userDAO.updateKakaoLink(user.getUserNo(), kakaoId.trim());
        return userDAO.selectUserByNo(user.getUserNo());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public UserVO joinKakaoUser(String kakaoId, String nickname, String email) {
        String normalizedKakaoId = InputValidator.trimToEmpty(kakaoId);
        if (normalizedKakaoId.isEmpty()) {
            throw new IllegalArgumentException("kakaoId must not be blank");
        }

        // 이미 연동된 계정이 있으면 반환
        UserVO existing = userDAO.selectUserByKakaoId(normalizedKakaoId);
        if (existing != null) {
            return existing;
        }

        // 신규 소셜 계정 생성
        String normalizedNickname = InputValidator.trimToEmpty(nickname);
        if (normalizedNickname.isEmpty()) {
            normalizedNickname = "카카오유저";
        }
        if (normalizedNickname.length() > USER_ID_MAX_LENGTH) {
            normalizedNickname = normalizedNickname.substring(0, USER_ID_MAX_LENGTH);
        }

        UserVO newUser = new UserVO();
        newUser.setUserId("kakao_" + normalizedKakaoId);
        // 소셜 전용 계정은 비밀번호 직접 로그인 불가 → UUID 해시로 채움
        newUser.setUserPw(DigestUtils.sha256Hex(java.util.UUID.randomUUID().toString()));
        newUser.setUserName(normalizedNickname);
        newUser.setUserEmail(InputValidator.trimToEmpty(email));
        newUser.setKakaoId(normalizedKakaoId);
        newUser.setLoginProvider("KAKAO");
        newUser.setUserRole("USER");

        userDAO.insertSocialUser(newUser);
        return userDAO.selectUserByNo(newUser.getUserNo());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void withdrawUser(int userNo) {
        UserVO user = userDAO.selectUserByNo(userNo);
        if (user == null) return;

        String mid = user.getUserId();

        // 1. 리뷰 좋아요 기록 삭제
        reviewDAO.deleteLikesByUserNo(userNo);

        // 2. 워치리스트 삭제
        try { watchlistDAO.deleteWatchlistByUserNo(userNo); } catch (Exception ignored) {}

        // 3. 봤어요 삭제
        try { watchedDAO.deleteWatchedByMid(mid); } catch (Exception ignored) {}

        // 4. 컬렉션 삭제 (collection_movie는 CASCADE)
        try { collectionDAO.deleteCollectionsByMid(mid); } catch (Exception ignored) {}

        // 5. 검색 기록 삭제
        try { searchHistoryDAO.deleteAllSearch(userNo); } catch (Exception ignored) {}

        // 6. 알림 삭제
        try { notificationDAO.deleteNotificationsByMid(mid); } catch (Exception ignored) {}

        // 7. 소프트 삭제 처리
        userDAO.softDeleteUser(userNo);

        // 8. 아이디 재사용 방지를 위해 탈퇴 아이디 보존
        try { userDAO.insertWithdrawnUserId(mid); } catch (Exception ignored) {}
        // 댓글·리뷰는 user_no → NULL (ON DELETE SET NULL) 로 자동 처리됨
    }
}
