package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.WatchlistVO;

@Mapper
public interface WatchlistDAO {

    int insertWatch(WatchlistVO vo);

    int deleteWatch(WatchlistVO vo);

    WatchlistVO selectWatch(WatchlistVO vo);

    List<WatchlistVO> selectWatchlistByUserNo(int userNo);

    int deleteWatchlistByUserNo(int userNo);
}
