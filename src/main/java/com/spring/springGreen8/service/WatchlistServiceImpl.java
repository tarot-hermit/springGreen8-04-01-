package com.spring.springGreen8.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.dao.WatchlistDAO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.WatchlistVO;

@Service
@Transactional(readOnly = true)
/**
 * 찜 목록의 비즈니스 로직 구현체.
 * TMDB 콘텐츠를 로컬 movie와 연결한 뒤 사용자별 watchlist 상태를 토글한다.
 */
public class WatchlistServiceImpl implements WatchlistService {

	@Autowired
	private WatchlistDAO watchlistDAO;
	
	@Autowired
	private MovieDAO movieDAO;
	
	@Autowired
	private TmdbService tmdbService;
	
	
	@Override
	@Transactional(rollbackFor = Exception.class)
	public String toggleWatch(WatchlistVO vo) {
		// tmdbId > movie_no 변환
		MovieVO movie = movieDAO.selectMovieByTmdbId(vo.getMovieNo());
		if (movie == null) {
			MovieVO tmdbMovie = tmdbService.getMovieDetail(vo.getMovieNo());
			if (tmdbMovie == null) return "fail";
			movieDAO.insertMovie(tmdbMovie);
			movie = movieDAO.selectMovieByTmdbId(vo.getMovieNo());
			// INSERT 직후 재조회 실패 방어 (NPE 방지)
			if (movie == null) return "fail";
		}
		vo.setMovieNo(movie.getMovieNo());
		
		// 이미 찜했으면 삭제
		WatchlistVO exist = watchlistDAO.selectWatch(vo);
		if (exist != null) {
			watchlistDAO.deleteWatch(vo);
			return "cancel";
		}
		// 없으면 추가 
		vo.setStatus("WANT");
		watchlistDAO.insertWatch(vo);
		return "ok";
	}

	@Override
	public WatchlistVO getWatch(WatchlistVO vo) {
		return watchlistDAO.selectWatch(vo);
	}

	@Override
	public List<WatchlistVO> getWatchlistByUserNo(int userNo) {
		return watchlistDAO.selectWatchlistByUserNo(userNo);
	}

}
