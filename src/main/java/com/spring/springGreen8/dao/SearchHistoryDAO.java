package com.spring.springGreen8.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import com.spring.springGreen8.vo.SearchHistoryVO;

@Mapper
public interface SearchHistoryDAO {
    // 검색 기록 저장
    int insertSearch(SearchHistoryVO vo);
    // 회원별 최근 검색어 조회
    List<SearchHistoryVO> selectSearchByUserNo(int userNo);
    // 검색어 삭제
    int deleteSearch(int searchNo);
    // 전체 삭제
    int deleteAllSearch(int userNo);

    // 사이트 전체 인기 검색어 TOP 10
    List<Map<String, Object>> selectPopularKeywords();
}
