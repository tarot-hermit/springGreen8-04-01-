package com.spring.springGreen8.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.SearchHistoryVO;

@Mapper
public interface SearchHistoryDAO {
    int insertSearch(SearchHistoryVO vo);

    List<SearchHistoryVO> selectSearchByUserNo(int userNo);

    int deleteSearch(@Param("searchNo") int searchNo, @Param("userNo") int userNo);

    int deleteAllSearch(int userNo);

    List<Map<String, Object>> selectPopularKeywords();
}
