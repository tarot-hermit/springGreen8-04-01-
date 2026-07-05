package com.spring.springGreen8.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.dao.ReviewDAO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.ReviewVO;

@Service
@Transactional(readOnly = true)
/**
 * 리뷰 기능의 비즈니스 로직 구현체.
 * TMDB 콘텐츠를 로컬 movie와 연결하고 리뷰 작성자 권한, 좋아요 수 재계산을 처리한다.
 */
public class ReviewServiceImpl implements ReviewService {
	
	@Autowired
	private ReviewDAO reviewDAO;
	
	@Autowired
	private MovieDAO movieDAO;
	
	@Autowired
	private TmdbService tmdbService;

	@Autowired
	private NotificationService notificationService;

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int writeReview(ReviewVO vo) {
		MovieVO movie = movieDAO.selectMovieByTmdbId(vo.getMovieNo());
		if (movie == null) {
			// TMDB에서 영화 정보 가져와서 DB 저장
			MovieVO tmdbMovie = tmdbService.getMovieDetail(vo.getMovieNo());
			if(tmdbMovie == null) return 0;
			movieDAO.insertMovie(tmdbMovie);
			movie = movieDAO.selectMovieByTmdbId(vo.getMovieNo());
			// 삽입 직후 재조회 실패 시 NPE 방지 — 리뷰 작성을 중단한다.
			if (movie == null) return 0;
		}
		vo.setMovieNo(movie.getMovieNo());
		return reviewDAO.insertReview(vo);
	}

	@Override
	public List<ReviewVO> getReviewsByMovieNo(int movieNo) {
		return reviewDAO.selectReviewsByMovieNo(movieNo);
	}

	@Override
	public ReviewVO getMyReview(ReviewVO vo) {
		return reviewDAO.selectMyReview(vo);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int updateReview(ReviewVO vo) {
		return reviewDAO.updateReview(vo);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int deleteReview(ReviewVO vo) {
		return reviewDAO.deleteReview(vo);
	}

	@Override
	public List<ReviewVO> getReviewsByUserNo(int userNo) {
		return reviewDAO.selectReviewsByUserNo(userNo);
	}
	
	@Override
	@Transactional(rollbackFor = Exception.class)
	public String toggleLike(int reviewNo, int userNo) {
	    ReviewVO vo = new ReviewVO();
	    vo.setReviewNo(reviewNo);
	    vo.setUserNo(userNo);

	    int cnt = reviewDAO.checkLike(vo);
	    if (cnt > 0) {
	        // 이미 공감 → 취소
	        reviewDAO.deleteLike(vo);
	    } else {
	        // 공감 추가
	        reviewDAO.insertLike(vo);
	    }
	    // 공감 수 업데이트
	    reviewDAO.updateLikeCnt(vo);

	    // 새로 공감(no-like → like)한 경우에만 알림 생성.
	    // 알림 실패가 공감 트랜잭션을 롤백하지 않도록 NotificationService가 best-effort 처리한다.
	    if (cnt == 0) {
	        notificationService.createLikeNotification(reviewNo, userNo);
	    }

	    return cnt > 0 ? "cancel" : "ok";
	}
	
	@Override
	public ReviewVO getReviewByNo(int reviewNo) {
	    return reviewDAO.selectReviewByNo(reviewNo);
	}
	
	@Override
	public List<Map<String, Object>> getRatingStats(int movieNo) {
	    return reviewDAO.getRatingStats(movieNo);
	}

	@Override
	public List<ReviewVO> getReviewsSorted(int movieNo, String sort) {
	    return reviewDAO.selectReviewsSorted(movieNo, sort);
	}
}
