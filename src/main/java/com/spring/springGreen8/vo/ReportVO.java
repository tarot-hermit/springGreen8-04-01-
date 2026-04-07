package com.spring.springGreen8.vo;

import java.util.Date;
import lombok.Data;

@Data
public class ReportVO {
    private int    reportId;
    private String reporterMid;   // 신고자 (user_id)
    private String targetType;    // REVIEW | COMMENT | MEMBER
    private int    targetId;      // 신고 대상 PK
    private String reason;        // 신고 사유
    private String status;        // PENDING | PROCESSED | REJECTED
    private Date   regDate;
    private int    tmdbId;
    private String movieTitle;
    private String targetContent;
}
