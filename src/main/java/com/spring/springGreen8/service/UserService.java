package com.spring.springGreen8.service;

import com.spring.springGreen8.vo.UserVO;

public interface UserService {
	// 회원가입
    int join(UserVO vo);
    // 아이디 중복 체크
    int checkId(String userId);
    // 로그인
    UserVO login(String userId, String userPw);
    // 회원정보 조회
    UserVO getUser(int userNo);
    // 회원정보 수정
    int updateUser(UserVO vo);
    // 프로필 이미지 수정
    int updateUserImg(UserVO vo);
    
    int checkEmail(String userEmail);
    
    int updatePw(UserVO vo);
    
	UserVO getUserByEmail(String userEmail);
	
	UserVO getUserByIdAndEmail(String userId, String userEmail);
	UserVO getUserByUserId(String userId);
}
