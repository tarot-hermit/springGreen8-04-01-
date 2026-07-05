package com.spring.springGreen8.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.CollectionDAO;
import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.vo.CollectionVO;
import com.spring.springGreen8.vo.MovieVO;

@Service
@Transactional(readOnly = true)
/**
 * 컬렉션 기능의 비즈니스 로직 구현체.
 * 소유자 권한, 입력값 길이, 중복 콘텐츠 여부를 확인한 뒤 컬렉션 데이터를 변경한다.
 */
public class CollectionServiceImpl implements CollectionService {

    @Autowired
    private CollectionDAO collectionDAO;

    @Autowired
    private MovieDAO movieDAO;

    @Autowired
    private TmdbService tmdbService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int createCollection(CollectionVO vo) {
        return collectionDAO.insertCollection(vo);
    }

    @Override
    public List<CollectionVO> getMyCollections(String mid) {
        return collectionDAO.selectMyCollections(mid, null);
    }

    @Override
    public List<CollectionVO> getMyCollections(String mid, Integer movieId) {
        return collectionDAO.selectMyCollections(mid, movieId);
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
    @Transactional(rollbackFor = Exception.class)
    public int updateCollection(CollectionVO vo) {
        return collectionDAO.updateCollection(vo);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteCollection(int collectionId, String mid) {
        return collectionDAO.deleteCollection(collectionId, mid);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String toggleCollectionMovie(int collectionId, int movieId) {
        int exists = collectionDAO.checkCollectionMovie(collectionId, movieId);
        if (exists > 0) {
            collectionDAO.deleteCollectionMovie(collectionId, movieId);
            return "removed";
        }

        MovieVO movie = ensureMovieMetadata(movieId);
        if (movie == null || movie.getTmdbId() <= 0) return "fail";

        collectionDAO.insertCollectionMovie(collectionId, movieId);
        return "added";
    }

    private MovieVO ensureMovieMetadata(int movieId) {
        MovieVO movie = movieDAO.selectMovieByTmdbId(movieId);
        if (movie != null) return movie;

        MovieVO tmdbMovie = tmdbService.getMovieDetail(movieId);
        if (tmdbMovie == null || tmdbMovie.getTmdbId() <= 0) return null;

        movieDAO.insertMovie(tmdbMovie);
        return movieDAO.selectMovieByTmdbId(movieId);
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
