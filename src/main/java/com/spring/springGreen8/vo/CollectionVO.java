package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class CollectionVO {
	private int collectionId;
	private String mid;			// userId (user_id)
	private String title;
	private String description;
	private int isPublic;		// 0:비공개 ,1: 공개
	private Date regDate;
	private Date updateDate;
	
	// JOIN 용
	private int movieCount;
}
