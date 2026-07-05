package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
/**
 * 최근 검색어와 검색 결과 수를 담는 값 객체.
 */
public class SearchHistoryVO {
	private int searchNo;
	private int userNo;
	private String keyword;
	private int resultCnt;
	private Date searchDate;
}
