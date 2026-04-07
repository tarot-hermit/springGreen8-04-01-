package com.spring.springGreen8.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.spring.springGreen8.vo.WatchedVO;

@Mapper
public interface WatchedDAO {

    // 봤어요 추가
    int insertWatched(WatchedVO vo);

    // 봤어요 취소
    int deleteWatched(@Param("mid")     String mid,
                      @Param("movieId") int movieId);

    // 봤어요 여부 확인 (1: 있음, 0: 없음)
    int checkWatched(@Param("mid")     String mid,
                     @Param("movieId") int movieId);

    // 내가 봤어요 한 영화 목록
    List<WatchedVO> selectMyWatched(@Param("mid") String mid);
}
