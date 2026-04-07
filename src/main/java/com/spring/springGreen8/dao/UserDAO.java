package com.spring.springGreen8.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.UserVO;

@Mapper
public interface UserDAO {
	 
		int insertUser(UserVO vo);

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
}
