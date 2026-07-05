package com.spring.springGreen8.vo;

import lombok.Data;

@Data
/**
 * 로컬 movie 테이블과 TMDB 영화 상세 정보를 담는 값 객체.
 */
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
	private boolean animation;
}
