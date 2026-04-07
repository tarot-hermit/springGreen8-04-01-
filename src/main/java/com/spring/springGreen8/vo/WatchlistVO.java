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

	    // JOIN용 (DB 컬럼 아님)
	    private String title;
	    private String posterPath;
	    private int tmdbId;
}
