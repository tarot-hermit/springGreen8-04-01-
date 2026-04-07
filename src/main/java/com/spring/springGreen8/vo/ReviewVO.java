package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class ReviewVO {
	private int reviewNo;
	private int movieNo;
	private int userNo;
	private double rating;
	private String content;
	private int spoiler;
	private int likeCnt;
	private Date regDate;
	private Date modDate;
	private String posterPath; 
	// JOIN용 (DB컬럼 아님)
	private String userName;
	private String userImg;
	private String title;
	
	private String movieTitle;  // 관리자 리뷰 목록에서 영화 제목 표시용
	private int tmdbId;         // 영화 상세 링크용
}
