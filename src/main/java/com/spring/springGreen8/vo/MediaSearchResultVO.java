package com.spring.springGreen8.vo;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class MediaSearchResultVO {
    private int page;
    private int totalPages;
    private int totalResults;
    private boolean hasNextPage;
    private List<MediaContentVO> contents = new ArrayList<>();
}
