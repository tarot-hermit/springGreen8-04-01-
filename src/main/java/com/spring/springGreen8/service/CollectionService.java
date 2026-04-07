package com.spring.springGreen8.service;

import java.util.List;
import com.spring.springGreen8.vo.CollectionVO;

public interface CollectionService {
    int createCollection(CollectionVO vo);
    List<CollectionVO> getMyCollections(String mid);
    List<CollectionVO> getPublicCollections();
    CollectionVO getCollectionById(int collectionId);
    int updateCollection(CollectionVO vo);
    int deleteCollection(int collectionId, String mid);
    // 영화 추가/제거 토글 → "added" | "removed"
    String toggleCollectionMovie(int collectionId, int movieId);
    boolean isMovieInCollection(int collectionId, int movieId);
    List<Integer> getMovieIds(int collectionId);
}
