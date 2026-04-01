package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class WatchlistVO {
	 	private int watchNo;
	    private int userNo;
	    private int movieNo;
	    private String status;  // WANT, WATCHED, STOP
	    private Date regDate;

	    // JOIN¿ë (DB ÄÃ·³ ¾Æ´Ô)
	    private String title;
	    private String posterPath;
	    private int tmdbId;
}
