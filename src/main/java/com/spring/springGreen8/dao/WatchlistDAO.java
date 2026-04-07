package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.springGreen8.vo.WatchlistVO;

@Mapper
public interface WatchlistDAO {
	// 찜 추가
	int insertWatch(WatchlistVO vo);
	// 찜 삭제
	int deleteWatch(WatchlistVO vo);
	// 찜 조회 (해당 유저 + 영화)
	WatchlistVO selectWatch(WatchlistVO vo);
	// 회원별 찜 목록
	List<WatchlistVO> selectWatchlistByUserNo(int userNo);
	// 상태 변경 (WANT > WATCHED 등)
	int updateWatchStatus(WatchlistVO vo);
	
}
