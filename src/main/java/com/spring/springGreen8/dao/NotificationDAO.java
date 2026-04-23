package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.NotificationVO;

@Mapper
public interface NotificationDAO {

    int insertNotification(NotificationVO vo);

    List<NotificationVO> selectMyNotifications(@Param("receiverMid") String receiverMid);

    // 내 알림 1건 조회 (소유권 동시 검증)
    NotificationVO selectNotificationById(@Param("notiId") int notiId,
                                          @Param("receiverMid") String receiverMid);

    int countUnread(@Param("receiverMid") String receiverMid);

    int markAsRead(@Param("notiId") int notiId, @Param("receiverMid") String receiverMid);

    int markAllAsRead(@Param("receiverMid") String receiverMid);

    int deleteNotificationsByMid(@Param("receiverMid") String receiverMid);
}
