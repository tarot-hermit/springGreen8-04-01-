package com.spring.springGreen8.vo;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
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
