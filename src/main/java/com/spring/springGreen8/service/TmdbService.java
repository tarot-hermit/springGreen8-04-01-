package com.spring.springGreen8.service;

import java.util.List;
import java.util.Map;

import com.spring.springGreen8.vo.MovieVO;

public interface TmdbService {
	 // 인기 영화 목록
    List<MovieVO> getPopularMovies(int page);
    // 현재 상영중
    List<MovieVO> getNowPlayingMovies(int page);
    // 최고 평점
    List<MovieVO> getTopRatedMovies(int page);
    // 영화 검색
    List<MovieVO> searchMovies(String query, int page);
    // 영화 상세
    MovieVO getMovieDetail(int tmdbId);
    // 장르별 영화 목록
    List<MovieVO> getMoviesByGenre(int genreId, int page);
    
    List<Map<String, Object>> getCastList(int tmdbId);
    List<Map<String, Object>> getCrewList(int tmdbId);
    List<Map<String, Object>> getVideoList(int tmdbId);
    Map<String, Object> getMovieCredits(int tmdbId);
    List<Map<String, Object>> getMovieVideos(int tmdbId);
    
    Map<String, Object> getPersonDetail(int personId);          // 배우 기본 정보
    List<Map<String, Object>> getPersonMovies(int personId);   // 출연 영화 목록
}
