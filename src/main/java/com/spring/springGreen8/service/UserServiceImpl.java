package com.spring.springGreen8.service;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.springGreen8.dao.UserDAO;
import com.spring.springGreen8.vo.UserVO;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserDAO userDAO;

    // 회원가입 (비밀번호 SHA-256 암호화)
    @Override
    public int join(UserVO vo) {
        vo.setUserPw(DigestUtils.sha256Hex(vo.getUserPw()));
        return userDAO.insertUser(vo);
    }

    // 아이디 중복 체크
    @Override
    public int checkId(String userId) {
        return userDAO.checkId(userId);
    }

    // 로그인 (비밀번호 암호화 후 비교)
    @Override
    public UserVO login(String userId, String userPw) {
        UserVO user = userDAO.selectUserById(userId);
        if (user != null) {
            String encPw = DigestUtils.sha256Hex(userPw);
            System.out.println("=== 로그인 디버그 ===");
            System.out.println("입력 ID   : " + userId);
            System.out.println("입력 암호화: " + encPw);
            System.out.println("DB 저장값 : " + user.getUserPw());
            System.out.println("일치여부  : " + encPw.equals(user.getUserPw()));
            if (encPw.equals(user.getUserPw())) {
                return user;
            }
        } else {
            System.out.println("=== 해당 아이디 없음: " + userId);
        }
        return null;
    }

    // 회원정보 조회
    @Override
    public UserVO getUser(int userNo) {
        return userDAO.selectUserByNo(userNo);
    }

    // 회원정보 수정
    @Override
    public int updateUser(UserVO vo) {
        return userDAO.updateUser(vo);
    }

    // 프로필 이미지 수정
    @Override
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
    public int updatePw(UserVO vo) {
        return userDAO.updatePw(vo);
    }
    
    @Override
    public UserVO getUserByEmail(String userEmail) {
        return userDAO.selectUserByEmail(userEmail);
    }
    
}