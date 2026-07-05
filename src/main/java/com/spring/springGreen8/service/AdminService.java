package com.spring.springGreen8.service;

/**
 * 관리자 기능의 서비스 계약.
 * 운영 통계 조회, 회원/리뷰/댓글 관리, 신고 처리 기능을 정의한다.
 */
public interface AdminService {

    String updateReportStatus(int reportId, String status);
}
