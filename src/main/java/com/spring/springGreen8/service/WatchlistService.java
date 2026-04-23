package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.WatchlistVO;

public interface WatchlistService {

    String toggleWatch(WatchlistVO vo);

    WatchlistVO getWatch(WatchlistVO vo);

    List<WatchlistVO> getWatchlistByUserNo(int userNo);
}
