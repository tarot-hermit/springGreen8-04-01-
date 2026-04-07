package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.WatchlistVO;

public interface WatchlistService {
	// 찜 토글 (있으면 삭제 , 없으면 추가)
	String toggleWatch(WatchlistVO vo);
	// 찜 여부 조회
	WatchlistVO getWatch(WatchlistVO vo);
	// 회원별 찜 목록
	List<WatchlistVO> getWatchlistByUserNo(int userNo);
	// 상태 변경
	int updateWatchStatus(WatchlistVO vo);
	
}
