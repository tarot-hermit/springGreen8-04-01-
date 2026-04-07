package com.spring.springGreen8.vo;

import lombok.Data;

@Data
public class EpisodeVO {
    private int episodeNumber;
    private String name;
    private String overview;
    private String stillPath;
    private String airDate;
    private int runtime;
    private double voteAverage;
}
