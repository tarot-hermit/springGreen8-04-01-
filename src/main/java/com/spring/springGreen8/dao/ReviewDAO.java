package com.spring.springGreen8.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

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
	
    // 별점 분포 (1~5점 각 카운트) — Map 반환
    // key: "star1"~"star5", value: COUNT
    List<Map<String, Object>> getRatingStats(int movieNo);

    // 정렬 옵션이 있는 리뷰 목록
    // sort: "latest"(최신) | "rating_high"(별점높은순) | "rating_low"(별점낮은순) | "like"(공감순)
    List<ReviewVO> selectReviewsSorted(@Param("movieNo") int movieNo,
                                       @Param("sort")    String sort);

}
