package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.springGreen8.vo.ReviewVO;

@Mapper
public interface ReviewDAO {
	//리뷰 등록
	int insertReview(ReviewVO vo);
	// 영화별 리뷰 목록
	List<ReviewVO> selectReviewsByMovieNo(int movieNo);
	// 내 리뷰 조회
	ReviewVO selectMyReview(ReviewVO vo);
	//리뷰 수정
	int updateReview(ReviewVO vo);
	// 리뷰 삭제
	int deleteReview(ReviewVO vo);
	// 회원별 리뷰 목록 (마이페이지)
	List<ReviewVO> selectReviewsByUserNo(int userNo);
	// 공감 추가
	int insertLike(ReviewVO vo);
	// 공감 취소
	int deleteLike(ReviewVO vo);
	// 공감 여부 확인
	int checkLike(ReviewVO vo);
	// 공감 수 업데이트
	int updateLikeCnt(ReviewVO vo);
	// 리뷰 단건 조회 추가
	ReviewVO selectReviewByNo(int reviewNo);
}
