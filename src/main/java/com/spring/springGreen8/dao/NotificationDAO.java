package com.spring.springGreen8.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.spring.springGreen8.vo.NotificationVO;

@Mapper
public interface NotificationDAO {

    // 알림 삽입
    int insertNotification(NotificationVO vo);

    // 내 알림 목록 (최신순 20개)
    List<NotificationVO> selectMyNotifications(@Param("receiverMid") String receiverMid);

    // 미읽음 알림 수 (뱃지용)
    int countUnread(@Param("receiverMid") String receiverMid);

    // 알림 읽음 처리 (단건)
    int markAsRead(@Param("notiId") int notiId);

    // 전체 읽음 처리
    int markAllAsRead(@Param("receiverMid") String receiverMid);
}
