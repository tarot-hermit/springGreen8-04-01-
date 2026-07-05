package com.spring.springGreen8.service;

import java.util.List;
import java.util.Map;

import com.spring.springGreen8.vo.ReviewVO;

/**
 * 리뷰 기능의 서비스 계약.
 * 리뷰 CRUD, 좋아요 토글, 별점 통계, 사용자별 리뷰 조회 기능을 정의한다.
 */
public interface ReviewService {
	//리뷰 등록
	int writeReview(ReviewVO vo);
	// 영화별 리뷰 목록
	List<ReviewVO> getReviewsByMovieNo(int movieNo);
	// 내 리뷰 조회
	ReviewVO getMyReview(ReviewVO vo);
	// 리뷰 수정
	int updateReview(ReviewVO vo);
	// 리뷰 삭제
	int deleteReview(ReviewVO vo);
	// 회원별 리뷰 목록
	List<ReviewVO> getReviewsByUserNo(int userNo);
	// 공감 토글
	String toggleLike(int reviewNo , int userNo);
	// 리뷰 단건 조회
	ReviewVO getReviewByNo(int reviewNo);
	
    // 별점 분포
    List<Map<String, Object>> getRatingStats(int movieNo);

    // 정렬 옵션 리뷰 목록
    List<ReviewVO> getReviewsSorted(int movieNo, String sort);

}
