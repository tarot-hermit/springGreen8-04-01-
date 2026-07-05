package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
/**
 * 리뷰 댓글과 답글 정보를 담는 값 객체.
 * parentId와 parentUserName으로 2-depth 댓글 표시를 지원한다.
 */
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
