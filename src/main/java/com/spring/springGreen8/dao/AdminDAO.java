package com.spring.springGreen8.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.ReportVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Mapper
public interface AdminDAO {

    // 대시보드 통계
    Map<String, Object> getDashboardStats();

    // 회원 전체 목록
    List<UserVO> getAllUsers();

    // 회원 등급 변경 (userNo 기반)
    int updateUserRole(@Param("userNo") int userNo,
                       @Param("userRole") String userRole);

    // 회원 강제 탈퇴 논리 삭제 (userNo 기반)
    int deleteUser(@Param("userNo") int userNo);

    // 리뷰 전체 목록
    List<ReviewVO> getAllReviews();

    // 리뷰 삭제
    int deleteReview(@Param("reviewId") int reviewId);

    // 신고 목록
    List<ReportVO> getAllReports();

    ReportVO getReportById(@Param("reportId") int reportId);

    int blindReview(@Param("reviewId") int reviewId,
                    @Param("blindMessage") String blindMessage);

    // 신고 상태 변경
    int updateReportStatus(@Param("reportId") int reportId,
                           @Param("status") String status);
}
