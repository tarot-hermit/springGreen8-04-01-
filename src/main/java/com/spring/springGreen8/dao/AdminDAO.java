package com.spring.springGreen8.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Mapper
public interface AdminDAO {

    // 대시보드 통계
    Map<String, Object> getDashboardStats();

    // 회원 전체 목록
    List<UserVO> getAllUsers();

    // 회원 역할 변경
    int updateUserRole(@Param("userNo") int userNo,
                       @Param("userRole") String userRole);

    // 회원 강제 탈퇴
    int deleteUser(int userNo);

    // 리뷰 전체 목록 (작성자명, 영화제목 포함)
    List<ReviewVO> getAllReviews();

    // 리뷰 강제 삭제
    int deleteReview(int reviewNo);
}