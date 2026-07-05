package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.WatchlistVO;

/**
 * 찜 목록 서비스 계약.
 * 보고 싶은 콘텐츠 저장/삭제 토글과 사용자별 찜 목록 조회 기능을 정의한다.
 */
public interface WatchlistService {

    String toggleWatch(WatchlistVO vo);

    WatchlistVO getWatch(WatchlistVO vo);

    List<WatchlistVO> getWatchlistByUserNo(int userNo);
}
