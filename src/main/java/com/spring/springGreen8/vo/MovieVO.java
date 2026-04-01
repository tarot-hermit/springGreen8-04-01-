package com.spring.springGreen8.vo;

import lombok.Data;

@Data
public class MovieVO {
	private int movieNo;
	private int tmdbId;
	private String title;
	private String titleEn;
	private String overview;
	private String posterPath;
	private String backdropPath;
	private String releaseDate;
	private int runtime;
	private double voteAverage;
	private double popularity;
	private String regDate;
	
	private double voteCount;
	private String originalTitle;
}
