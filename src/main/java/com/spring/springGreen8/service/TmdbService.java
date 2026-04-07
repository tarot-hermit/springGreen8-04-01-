package com.spring.springGreen8.service;

import java.util.List;
import java.util.Map;

import com.spring.springGreen8.vo.MediaContentVO;
import com.spring.springGreen8.vo.MediaSearchResultVO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.OttProviderVO;
import com.spring.springGreen8.vo.SeasonVO;

public interface TmdbService {
    List<MovieVO> getPopularMovies(int page);
    List<MovieVO> getPopularMovies(int page, String countryCode);
    List<MovieVO> getNowPlayingMovies(int page);
    List<MovieVO> getNowPlayingMovies(int page, String countryCode);
    List<MovieVO> getTopRatedMovies(int page);
    List<MovieVO> getTopRatedMovies(int page, String countryCode);
    List<MediaContentVO> getPopularTvShows(int page);
    List<MediaContentVO> getPopularTvShows(int page, String countryCode);
    List<MediaContentVO> getTopRatedTvShows(int page);
    List<MediaContentVO> getTopRatedTvShows(int page, String countryCode);
    List<MediaContentVO> getOnTheAirTvShows(int page);
    List<MediaContentVO> getOnTheAirTvShows(int page, String countryCode);
    List<MediaContentVO> getAnimationMovies(int page);
    List<MediaContentVO> getAnimationMovies(int page, String countryCode);
    List<MediaContentVO> getAnimationTvShows(int page);
    List<MediaContentVO> getAnimationTvShows(int page, String countryCode);
    List<MovieVO> searchMovies(String query, int page);
    MediaSearchResultVO searchContents(String query, int page, String mediaType, String countryCode);
    MovieVO getMovieDetail(int tmdbId);
    MediaContentVO getTvDetail(int tmdbId);
    SeasonVO getTvSeasonDetail(int tmdbId, int seasonNo);
    List<MovieVO> getMoviesByGenre(int genreId, int page);
    MediaSearchResultVO getContentsByGenre(int genreId, int page);

    List<Map<String, Object>> getCastList(int tmdbId);
    List<Map<String, Object>> getCrewList(int tmdbId);
    List<Map<String, Object>> getVideoList(int tmdbId);
    List<Map<String, Object>> getTvCastList(int tmdbId);
    List<Map<String, Object>> getTvCrewList(int tmdbId);
    List<Map<String, Object>> getTvVideoList(int tmdbId);
    List<Map<String, Object>> getTvSeasonVideoList(int tmdbId, int seasonNo);
    Map<String, Object> getMovieCredits(int tmdbId);
    List<Map<String, Object>> getMovieVideos(int tmdbId);
    List<OttProviderVO> getMovieWatchProviders(int tmdbId, String regionCode);
    List<OttProviderVO> getTvWatchProviders(int tmdbId, String regionCode);

    Map<String, Object> getPersonDetail(int personId);
    List<Map<String, Object>> getPersonMovies(int personId);

    List<MovieVO> getUpcomingMovies(int page);
    List<MovieVO> getTrendingMovies(String timeWindow);
    List<Map<String, Object>> getMovieKeywords(int tmdbId);
    List<MovieVO> getSimilarMovies(int tmdbId, int page);
}
