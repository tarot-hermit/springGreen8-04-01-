package com.spring.springGreen8.vo;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
/**
 * 드라마 시즌 정보와 에피소드 목록을 담는 값 객체.
 */
public class SeasonVO {
    private int seasonNumber;
    private String name;
    private String overview;
    private String posterPath;
    private String airDate;
    private int episodeCount;
    private List<EpisodeVO> episodes = new ArrayList<>();
}
