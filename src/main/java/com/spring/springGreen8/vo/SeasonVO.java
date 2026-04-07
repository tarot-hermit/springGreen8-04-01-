package com.spring.springGreen8.vo;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class SeasonVO {
    private int seasonNumber;
    private String name;
    private String overview;
    private String posterPath;
    private String airDate;
    private int episodeCount;
    private List<EpisodeVO> episodes = new ArrayList<>();
}
