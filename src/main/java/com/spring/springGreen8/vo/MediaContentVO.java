package com.spring.springGreen8.vo;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
/**
 * 영화/드라마/애니메이션 공통 콘텐츠 정보를 담는 값 객체.
 * TMDB 응답을 화면 표시용 데이터로 변환할 때 사용한다.
 */
public class MediaContentVO {
    private int tmdbId;
    private String mediaType;
    private String title;
    private String originalTitle;
    private String overview;
    private String posterPath;
    private String backdropPath;
    private String releaseDate;
    private int runtime;
    private int seasonCount;
    private int episodeCount;
    private double voteAverage;
    private double popularity;
    private String originalLanguage;
    private boolean animation;
    private List<Integer> genreIds = new ArrayList<>();
    private List<String> genreNames = new ArrayList<>();
    private List<String> originCountries = new ArrayList<>();
    private List<SeasonVO> seasons = new ArrayList<>();
}
