package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.MediaVideoCacheVO;

@Mapper
/**
 * TMDB/YouTube 예고편 캐시 DB 접근 인터페이스.
 * 외부 API 호출 결과를 저장해 상세 페이지 예고편 fallback 속도와 안정성을 높인다.
 */
public interface MediaVideoCacheDAO {
    List<MediaVideoCacheVO> selectVideoCache(@Param("mediaType") String mediaType,
                                             @Param("tmdbId") int tmdbId,
                                             @Param("seasonNo") Integer seasonNo);

    int deleteVideoCache(@Param("mediaType") String mediaType,
                         @Param("tmdbId") int tmdbId,
                         @Param("seasonNo") Integer seasonNo);

    int insertVideoCache(MediaVideoCacheVO vo);
}
