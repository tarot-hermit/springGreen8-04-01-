package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.WatchlistVO;

@Mapper
/**
 * 찜 목록 DB 접근 인터페이스.
 * 사용자가 보고 싶은 콘텐츠를 저장/삭제하고 마이페이지 목록으로 조회한다.
 */
public interface WatchlistDAO {

    int insertWatch(WatchlistVO vo);

    int deleteWatch(WatchlistVO vo);

    WatchlistVO selectWatch(WatchlistVO vo);

    List<WatchlistVO> selectWatchlistByUserNo(int userNo);

    int deleteWatchlistByUserNo(int userNo);
}
