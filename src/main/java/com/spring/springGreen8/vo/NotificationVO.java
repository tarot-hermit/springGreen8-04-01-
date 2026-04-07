package com.spring.springGreen8.vo;

import java.util.Date;
import lombok.Data;

@Data
public class NotificationVO {
    private int    notiId;
    private String receiverMid;   // 알림 받는 사람 (user_id)
    private String senderMid;     // 알림 발생시킨 사람 (user_id)
    private String notiType;      // COMMENT | LIKE | REVIEW
    private int    refId;         // 참조 PK (review_id / comment_id)
    private String message;       // 알림 본문
    private int    isRead;        // 0: 미읽음, 1: 읽음
    private Date   regDate;
}
