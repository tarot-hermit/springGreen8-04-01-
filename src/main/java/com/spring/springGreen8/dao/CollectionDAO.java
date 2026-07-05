package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.CollectionVO;

@Mapper
/**
 * 사용자 컬렉션 DB 접근 인터페이스.
 * 컬렉션 기본 정보와 컬렉션-콘텐츠 매핑 테이블을 조회/저장한다.
 */
public interface CollectionDAO {

    // 컬렉션 생성
    int insertCollection(CollectionVO vo);

    // 내 컬렉션 목록
    List<CollectionVO> selectMyCollections(@Param("mid") String mid,
                                           @Param("movieId") Integer movieId);

    // 공개 컬렉션 목록 (탐색 페이지)
    List<CollectionVO> selectPublicCollections();

    // 컬렉션 단건 조회
    CollectionVO selectCollectionById(@Param("collectionId") int collectionId);

    // 컬렉션 수정
    int updateCollection(CollectionVO vo);

    // 컬렉션 삭제 (collection_movie 는 CASCADE 로 자동 삭제)
    int deleteCollection(@Param("collectionId") int collectionId,
                         @Param("mid")          String mid);

    // 영화 추가
    int insertCollectionMovie(@Param("collectionId") int collectionId,
                              @Param("movieId")      int movieId);

    // 영화 제거
    int deleteCollectionMovie(@Param("collectionId") int collectionId,
                              @Param("movieId")      int movieId);

    // 컬렉션에 담긴 영화 목록 (TMDB id 기준)
    List<Integer> selectMovieIdsByCollection(@Param("collectionId") int collectionId);

    // 영화가 컬렉션에 있는지 확인
    int checkCollectionMovie(@Param("collectionId") int collectionId,
                             @Param("movieId")      int movieId);

    // 회원 탈퇴 시 해당 회원 컬렉션 전체 삭제
    int deleteCollectionsByMid(@Param("mid") String mid);
}
