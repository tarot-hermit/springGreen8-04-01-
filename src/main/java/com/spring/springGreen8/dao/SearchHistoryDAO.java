package com.spring.springGreen8.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.SearchHistoryVO;

@Mapper
/**
 * 검색 기록 DB 접근 인터페이스.
 * 최근 검색어 저장, 중복 정리, 인기 검색어 집계 SQL을 담당한다.
 */
public interface SearchHistoryDAO {
    int insertSearch(SearchHistoryVO vo);

    List<SearchHistoryVO> selectSearchByUserNo(int userNo);

    int deleteSearch(@Param("searchNo") int searchNo, @Param("userNo") int userNo);

    int deleteAllSearch(int userNo);

    int deleteSearchByKeyword(@Param("userNo") int userNo, @Param("keyword") String keyword);

    List<Map<String, Object>> selectPopularKeywords();
}
