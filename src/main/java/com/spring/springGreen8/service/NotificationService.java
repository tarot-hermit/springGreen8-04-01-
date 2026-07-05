package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.CommentVO;
import com.spring.springGreen8.vo.NotificationVO;

/**
 * 알림(Notification) 관련 비즈니스 로직.
 * - 댓글/공감/신고처리 등 도메인 이벤트에 대한 알림 생성 책임을 중앙화한다.
 * - 컨트롤러 전용 조회/읽음 처리 위임 메서드도 함께 제공한다.
 */
/**
 * 알림 기능의 서비스 계약.
 * 댓글, 좋아요, 신고 결과 알림 생성과 조회/읽음 처리 기능을 정의한다.
 */
public interface NotificationService {

    /**
     * 댓글 작성 시 리뷰 작성자에게 알림을 생성한다.
     * 현재 트랜잭션에 참여하며, 실패 시 예외를 던져 롤백을 유도한다.
     */
    void createCommentNotification(CommentVO vo, String senderUserId);

    /**
     * 대댓글 작성 시 부모 댓글 작성자에게 알림을 생성한다.
     * (2차 기능 - 아직 구현체 미연결. handoff 문서 참조)
     */
    void createReplyNotification(CommentVO reply, CommentVO parent, String senderUserId);

    /**
     * 리뷰 공감(좋아요) 시 리뷰 작성자에게 알림을 생성한다.
     * 알림 실패는 best-effort로 삼켜 공감 트랜잭션에 영향을 주지 않는다.
     */
    void createLikeNotification(int reviewNo, int likerUserNo);

    /**
     * 신고 처리(PROCESSED/REJECTED) 시 신고자에게 결과 알림을 생성한다.
     * 시스템 알림이므로 senderMid는 null. best-effort 처리.
     */
    void createReportResultNotification(int reportId, String newStatus);

    // ── 컨트롤러 위임 메서드 ─────────────────────────────────

    int countUnread(String receiverMid);

    List<NotificationVO> getMyNotifications(String receiverMid);

    /** 내 알림 1건 조회 (소유권을 함께 검증, 아니면 null 반환). */
    NotificationVO getNotification(int notiId, String receiverMid);

    int markAsRead(int notiId, String receiverMid);

    int markAllAsRead(String receiverMid);
}
