package com.spring.springGreen8.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.spring.springGreen8.vo.WatchedVO;

@Mapper
/**
 * '봤어요' 기록 DB 접근 인터페이스.
 * 사용자별 시청 완료 콘텐츠의 저장, 삭제, 목록 조회 SQL을 담당한다.
 */
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

    // 회원 탈퇴 시 봤어요 전체 삭제
    int deleteWatchedByMid(@Param("mid") String mid);
}
