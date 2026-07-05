package com.spring.springGreen8.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.spring.springGreen8.dao.WatchedDAO;
import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.WatchedVO;

@Service
@Transactional(readOnly = true)
/**
 * '봤어요' 기록의 비즈니스 로직 구현체.
 * TMDB 콘텐츠를 로컬 movie와 연결한 뒤 사용자 시청 완료 상태를 토글한다.
 */
public class WatchedServiceImpl implements WatchedService {

    @Autowired
    private WatchedDAO watchedDAO;

    @Autowired
    private MovieDAO movieDAO;

    @Autowired
    private TmdbService tmdbService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String toggleWatched(String mid, int movieId) {
        int exists = watchedDAO.checkWatched(mid, movieId);
        if (exists > 0) {
            watchedDAO.deleteWatched(mid, movieId);
            return "removed";
        } else {
            ensureMovieMetadata(movieId);
            WatchedVO vo = new WatchedVO();
            vo.setMid(mid);
            vo.setMovieId(movieId);
            watchedDAO.insertWatched(vo);
            return "added";
        }
    }

    private void ensureMovieMetadata(int movieId) {
        MovieVO movie = movieDAO.selectMovieByTmdbId(movieId);
        if (movie != null) return;

        MovieVO tmdbMovie = tmdbService.getMovieDetail(movieId);
        if (tmdbMovie != null) {
            movieDAO.insertMovie(tmdbMovie);
        }
    }

    @Override
    public boolean isWatched(String mid, int movieId) {
        return watchedDAO.checkWatched(mid, movieId) > 0;
    }

    @Override
    public List<WatchedVO> getMyWatched(String mid) {
        return watchedDAO.selectMyWatched(mid);
    }
}
