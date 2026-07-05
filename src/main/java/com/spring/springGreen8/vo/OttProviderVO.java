package com.spring.springGreen8.vo;

import lombok.Data;

@Data
/**
 * 콘텐츠별 OTT 제공처 정보를 담는 값 객체.
 */
public class OttProviderVO {
    private int providerId;
    private String providerName;
    private String logoPath;
    private int displayPriority;
    private String providerType;
    private String regionCode;
}
