package com.spring.springGreen8.dao;

import org.apache.ibatis.annotations.Mapper;

import com.spring.springGreen8.vo.MovieVO;

@Mapper
/**
 * 로컬 콘텐츠 DB 접근 인터페이스.
 * TMDB 콘텐츠를 movie 테이블에 저장하고 tmdb_id와 movie_no를 연결한다.
 */
public interface MovieDAO {
	MovieVO selectMovieByTmdbId(int tmdbId);
	
	int insertMovie(MovieVO vo);
	
	MovieVO selectMovieByNo(int movieNo);
}
