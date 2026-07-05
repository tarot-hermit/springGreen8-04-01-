package com.spring.springGreen8.vo;

import lombok.Data;

@Data
/**
 * 드라마 시즌의 에피소드 정보를 담는 값 객체.
 */
public class EpisodeVO {
    private int episodeNumber;
    private String name;
    private String overview;
    private String stillPath;
    private String airDate;
    private int runtime;
    private double voteAverage;
}
