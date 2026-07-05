package com.spring.springGreen8.vo;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
/**
 * 통합 검색 결과와 페이징 정보를 함께 담는 값 객체.
 */
public class MediaSearchResultVO {
    private int page;
    private int totalPages;
    private int totalResults;
    private boolean hasNextPage;
    private List<MediaContentVO> contents = new ArrayList<>();
}
