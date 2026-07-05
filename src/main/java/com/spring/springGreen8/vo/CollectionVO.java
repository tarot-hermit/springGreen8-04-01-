package com.spring.springGreen8.vo;

import java.util.Date;

import lombok.Data;

@Data
/**
 * 사용자 컬렉션과 컬렉션-콘텐츠 매핑 정보를 담는 값 객체.
 */
public class CollectionVO {
    private int collectionId;
    private String mid;         // userId (user_id)
    private String title;
    private String description;
    private int isPublic;       // 0:비공개, 1:공개
    private Date regDate;
    private Date updateDate;

    // JOIN fields
    private int movieCount;
    private boolean inCollection;
}
