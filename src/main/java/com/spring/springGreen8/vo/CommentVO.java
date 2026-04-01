package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class CommentVO {
	private int commentNo;
	private int reviewNo;
	private int userNo;
	private String content;
	private Date regDate;
	
	// JOIN¿ë
	private String userName;
	private String userImg;
}
