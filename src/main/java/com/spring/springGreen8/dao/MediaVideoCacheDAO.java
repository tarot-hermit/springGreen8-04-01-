package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.MediaVideoCacheVO;

@Mapper
public interface MediaVideoCacheDAO {
    List<MediaVideoCacheVO> selectVideoCache(@Param("mediaType") String mediaType,
                                             @Param("tmdbId") int tmdbId,
                                             @Param("seasonNo") Integer seasonNo);

    int deleteVideoCache(@Param("mediaType") String mediaType,
                         @Param("tmdbId") int tmdbId,
                         @Param("seasonNo") Integer seasonNo);

    int insertVideoCache(MediaVideoCacheVO vo);
}
