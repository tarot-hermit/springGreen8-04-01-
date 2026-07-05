package com.spring.springGreen8.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.UserVO;

@Mapper
/**
 * 회원 계정 DB 접근 인터페이스.
 * 가입, 로그인 조회, 프로필 수정, 카카오 연동, 탈퇴 처리를 담당한다.
 */
public interface UserDAO {
	 
		int insertUser(UserVO vo);

		int insertSocialUser(UserVO vo);

	    // 아이디 중복 체크
	    int checkId(String userId);

	    // 로그인 (아이디로 회원 조회)
	    UserVO selectUserById(String userId);

	    // 회원정보 조회 (번호로)
	    UserVO selectUserByNo(int userNo);

	    // 회원정보 수정
	    int updateUser(UserVO vo);

	    // 프로필 이미지 수정
	    int updateUserImg(UserVO vo);
	    
	    int checkEmail(String userEmail);
	    
	    UserVO selectUserByIdAndEmail(@Param("userId") String userId,
                @Param("userEmail") String userEmail);
	    
	    int updatePw(UserVO vo);
	    
	    UserVO selectUserByEmail(String userEmail);

	    UserVO selectUserByKakaoId(String kakaoId);

	    int updateKakaoLink(@Param("userNo") int userNo, @Param("kakaoId") String kakaoId);

    // 회원 탈퇴 (소프트 삭제)
    int softDeleteUser(int userNo);

    // 탈퇴 아이디 보존 (중복 가입 방지)
    int insertWithdrawnUserId(String userId);
}
