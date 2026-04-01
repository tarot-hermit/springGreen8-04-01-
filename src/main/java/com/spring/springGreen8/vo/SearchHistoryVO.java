package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
public class SearchHistoryVO {
	private int searchNo;
	private int userNo;
	private String keyword;
	private int resultCnt;
	private Date searchDate;
}
