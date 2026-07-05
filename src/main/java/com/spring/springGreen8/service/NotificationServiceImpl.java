package com.spring.springGreen8.service;

import java.util.Collections;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.AdminDAO;
import com.spring.springGreen8.dao.MovieDAO;
import com.spring.springGreen8.dao.NotificationDAO;
import com.spring.springGreen8.vo.CommentVO;
import com.spring.springGreen8.vo.MovieVO;
import com.spring.springGreen8.vo.NotificationVO;
import com.spring.springGreen8.vo.ReportVO;
import com.spring.springGreen8.vo.ReviewVO;
import com.spring.springGreen8.vo.UserVO;

@Service
@Transactional(readOnly = true)
/**
 * 알림 기능의 비즈니스 로직 구현체.
 * 서비스 이벤트를 사용자 알림 데이터로 변환하고 중복/읽음 상태를 관리한다.
 */
public class NotificationServiceImpl implements NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationServiceImpl.class);

    @Autowired
    private NotificationDAO notificationDAO;

    @Autowired
    private ReviewService reviewService;

    @Autowired
    private UserService userService;

    @Autowired
    private MovieDAO movieDAO;

    @Autowired
    private AdminDAO adminDAO;

    // ── 댓글 알림 ─────────────────────────────────────────
    // REQUIRES_NEW: 알림 삽입 실패가 댓글 트랜잭션까지 롤백시키지 않도록 별도 트랜잭션으로 분리
    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void createCommentNotification(CommentVO vo, String senderUserId) {
        ReviewVO review = reviewService.getReviewByNo(vo.getReviewNo());
        if (review == null || review.getUserNo() == vo.getUserNo()) return;

        UserVO reviewOwner = userService.getUser(review.getUserNo());
        if (reviewOwner == null) return;

        MovieVO movie = movieDAO.selectMovieByNo(review.getMovieNo());
        int tmdbId = (movie != null) ? movie.getTmdbId() : review.getMovieNo();

        NotificationVO noti = new NotificationVO();
        noti.setReceiverMid(reviewOwner.getUserId());
        noti.setSenderMid(senderUserId);
        noti.setNotiType("COMMENT");
        noti.setRefId(tmdbId);
        noti.setMessage(senderUserId + "님이 회원님의 리뷰에 댓글을 작성했습니다.");

        if (notificationDAO.insertNotification(noti) <= 0) {
            throw new IllegalStateException("Failed to insert comment notification");
        }
    }

    // ── 대댓글 알림 (2차 기능: handoff 문서에 따라 구현 예정) ────
    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void createReplyNotification(CommentVO reply, CommentVO parent, String senderUserId) {
        // TODO(2차): parentId 기반 대댓글 알림 구현
        // - parent.getUserNo() 소유자에게 알림
        // - self-reply 스킵
        // - refId는 리뷰의 tmdbId
        log.info("createReplyNotification stub called (sender={})", senderUserId);
    }

    // ── 공감(좋아요) 알림 ────────────────────────────────
    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void createLikeNotification(int reviewNo, int likerUserNo) {
        try {
            ReviewVO review = reviewService.getReviewByNo(reviewNo);
            if (review == null) return;
            if (review.getUserNo() == likerUserNo) return;

            UserVO reviewOwner = userService.getUser(review.getUserNo());
            if (reviewOwner == null) return;

            UserVO liker = userService.getUser(likerUserNo);
            if (liker == null) return;

            MovieVO movie = movieDAO.selectMovieByNo(review.getMovieNo());
            int tmdbId = (movie != null) ? movie.getTmdbId() : review.getMovieNo();

            NotificationVO noti = new NotificationVO();
            noti.setReceiverMid(reviewOwner.getUserId());
            noti.setSenderMid(liker.getUserId());
            noti.setNotiType("LIKE");
            noti.setRefId(tmdbId);
            noti.setMessage(liker.getUserId() + "님이 회원님의 리뷰에 공감했습니다.");

            int inserted = notificationDAO.insertNotification(noti);
            if (inserted <= 0) {
                log.warn("createLikeNotification: insert returned 0 (reviewNo={}, likerUserNo={})",
                         reviewNo, likerUserNo);
            }
        } catch (Exception e) {
            log.warn("createLikeNotification failed reviewNo=" + reviewNo
                    + ", likerUserNo=" + likerUserNo, e);
        }
    }

    // ── 신고 처리 결과 알림 ────────────────────────────────
    @Override
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void createReportResultNotification(int reportId, String newStatus) {
        try {
            if (newStatus == null) return;
            String normalized = newStatus.trim().toUpperCase();
            if (!"PROCESSED".equals(normalized) && !"REJECTED".equals(normalized)) return;

            ReportVO report = adminDAO.getReportById(reportId);
            if (report == null) return;
            if (report.getReporterMid() == null || report.getReporterMid().isEmpty()) return;

            String targetTypeLabel = "REVIEW".equalsIgnoreCase(report.getTargetType())
                    ? "리뷰"
                    : "COMMENT".equalsIgnoreCase(report.getTargetType())
                        ? "댓글"
                        : "게시물";

            String resultLabel = "PROCESSED".equals(normalized) ? "처리(블라인드)" : "반려";
            String message = "신고하신 " + targetTypeLabel + "이(가) " + resultLabel + " 되었습니다.";

            NotificationVO noti = new NotificationVO();
            noti.setReceiverMid(report.getReporterMid());
            noti.setSenderMid(null);
            noti.setNotiType("REPORT");
            noti.setRefId(reportId);
            noti.setMessage(message);

            int inserted = notificationDAO.insertNotification(noti);
            if (inserted <= 0) {
                log.warn("createReportResultNotification: insert returned 0 (reportId={}, status={})",
                         reportId, newStatus);
            }
        } catch (Exception e) {
            log.warn("createReportResultNotification failed reportId=" + reportId
                    + ", status=" + newStatus, e);
        }
    }

    // ── 컨트롤러 위임 ─────────────────────────────────────

    @Override
    public int countUnread(String receiverMid) {
        if (receiverMid == null) return 0;
        return notificationDAO.countUnread(receiverMid);
    }

    @Override
    public List<NotificationVO> getMyNotifications(String receiverMid) {
        if (receiverMid == null) return Collections.emptyList();
        return notificationDAO.selectMyNotifications(receiverMid);
    }

    @Override
    public NotificationVO getNotification(int notiId, String receiverMid) {
        if (receiverMid == null || notiId <= 0) return null;
        return notificationDAO.selectNotificationById(notiId, receiverMid);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markAsRead(int notiId, String receiverMid) {
        if (receiverMid == null) return 0;
        return notificationDAO.markAsRead(notiId, receiverMid);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int markAllAsRead(String receiverMid) {
        if (receiverMid == null) return 0;
        return notificationDAO.markAllAsRead(receiverMid);
    }
}
