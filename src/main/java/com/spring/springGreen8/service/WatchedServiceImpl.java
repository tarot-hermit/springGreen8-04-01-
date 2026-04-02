package com.spring.springGreen8.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.spring.springGreen8.dao.WatchedDAO;
import com.spring.springGreen8.vo.WatchedVO;

@Service
public class WatchedServiceImpl implements WatchedService {

    @Autowired
    private WatchedDAO watchedDAO;

    @Override
    public String toggleWatched(String mid, int movieId) {
        int exists = watchedDAO.checkWatched(mid, movieId);
        if (exists > 0) {
            watchedDAO.deleteWatched(mid, movieId);
            return "removed";
        } else {
            WatchedVO vo = new WatchedVO();
            vo.setMid(mid);
            vo.setMovieId(movieId);
            watchedDAO.insertWatched(vo);
            return "added";
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
