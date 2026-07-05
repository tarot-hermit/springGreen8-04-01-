package com.spring.springGreen8.vo;

import lombok.Data;

@Data
/**
 * TMDB/YouTube 예고편 캐시 정보를 담는 값 객체.
 */
public class MediaVideoCacheVO {
    private int cacheNo;
    private int tmdbId;
    private String mediaType;
    private Integer seasonNo;
    private String sourceType;
    private String videoKey;
    private String videoName;
    private String videoSite;
    private String videoType;
    private int displayOrder;
    private String regDate;
}
