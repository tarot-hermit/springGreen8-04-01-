package com.spring.springGreen8.service;

import java.util.List;
import com.spring.springGreen8.vo.CollectionVO;

/**
 * 컬렉션 기능의 서비스 계약.
 * 컬렉션 CRUD, 공개/비공개 제어, 콘텐츠 추가/제거 기능을 정의한다.
 */
public interface CollectionService {
    int createCollection(CollectionVO vo);
    List<CollectionVO> getMyCollections(String mid);
    List<CollectionVO> getMyCollections(String mid, Integer movieId);
    List<CollectionVO> getPublicCollections();
    CollectionVO getCollectionById(int collectionId);
    int updateCollection(CollectionVO vo);
    int deleteCollection(int collectionId, String mid);
    // 영화 추가/제거 토글 → "added" | "removed"
    String toggleCollectionMovie(int collectionId, int movieId);
    boolean isMovieInCollection(int collectionId, int movieId);
    List<Integer> getMovieIds(int collectionId);
}
