package com.spring.springGreen8.vo;

import lombok.Data;

@Data
public class OttProviderVO {
    private int providerId;
    private String providerName;
    private String logoPath;
    private int displayPriority;
    private String providerType;
    private String regionCode;
}
