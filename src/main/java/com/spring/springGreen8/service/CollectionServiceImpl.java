package com.spring.springGreen8.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.spring.springGreen8.dao.CollectionDAO;
import com.spring.springGreen8.vo.CollectionVO;

@Service
public class CollectionServiceImpl implements CollectionService {

    @Autowired
    private CollectionDAO collectionDAO;

    @Override
    public int createCollection(CollectionVO vo) {
        return collectionDAO.insertCollection(vo);
    }

    @Override
    public List<CollectionVO> getMyCollections(String mid) {
        return collectionDAO.selectMyCollections(mid);
    }

    @Override
    public List<CollectionVO> getPublicCollections() {
        return collectionDAO.selectPublicCollections();
    }

    @Override
    public CollectionVO getCollectionById(int collectionId) {
        return collectionDAO.selectCollectionById(collectionId);
    }

    @Override
    public int updateCollection(CollectionVO vo) {
        return collectionDAO.updateCollection(vo);
    }

    @Override
    public int deleteCollection(int collectionId, String mid) {
        return collectionDAO.deleteCollection(collectionId, mid);
    }

    @Override
    public String toggleCollectionMovie(int collectionId, int movieId) {
        int exists = collectionDAO.checkCollectionMovie(collectionId, movieId);
        if (exists > 0) {
            collectionDAO.deleteCollectionMovie(collectionId, movieId);
            return "removed";
        } else {
            collectionDAO.insertCollectionMovie(collectionId, movieId);
            return "added";
        }
    }

    @Override
    public boolean isMovieInCollection(int collectionId, int movieId) {
        return collectionDAO.checkCollectionMovie(collectionId, movieId) > 0;
    }

    @Override
    public List<Integer> getMovieIds(int collectionId) {
        return collectionDAO.selectMovieIdsByCollection(collectionId);
    }
}
