package com.spring.springGreen8.dao;

import org.apache.ibatis.annotations.Mapper;

import com.spring.springGreen8.vo.MovieVO;

@Mapper
public interface MovieDAO {
	MovieVO selectMovieByTmdbId(int tmdbId);
	
	int insertMovie(MovieVO vo);
}
