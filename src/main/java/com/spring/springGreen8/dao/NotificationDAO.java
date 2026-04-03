package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.NotificationVO;

@Mapper
public interface NotificationDAO {

    int insertNotification(NotificationVO vo);

    List<NotificationVO> selectMyNotifications(@Param("receiverMid") String receiverMid);

    int countUnread(@Param("receiverMid") String receiverMid);

    int markAsRead(@Param("notiId") int notiId, @Param("receiverMid") String receiverMid);

    int markAllAsRead(@Param("receiverMid") String receiverMid);
}
