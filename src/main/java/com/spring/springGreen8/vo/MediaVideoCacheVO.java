package com.spring.springGreen8.vo;

import lombok.Data;

@Data
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
