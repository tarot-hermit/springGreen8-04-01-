package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class CommentVO {
	private int commentNo;
	private int reviewNo;
	private Integer parentId;
	private int userNo;
	private String content;
	private Date regDate;

	// JOIN용
	private String userName;
	private String userImg;
	private String parentUserName;
}
