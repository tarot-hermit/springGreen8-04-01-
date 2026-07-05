package com.spring.springGreen8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.AdminDAO;
import com.spring.springGreen8.vo.ReportVO;

@Service
/**
 * 관리자 기능의 비즈니스 로직 구현체.
 * 신고 처리 시 리뷰 블라인드, 알림 생성, 회원 세션 정리 같은 운영 결과를 함께 반영한다.
 */
public class AdminServiceImpl implements AdminService {

    private static final String BLIND_REVIEW_MESSAGE =
            "\uC2E0\uACE0\uB85C \uC778\uD574 \uBE14\uB77C\uC778\uB4DC \uCC98\uB9AC\uB41C \uB9AC\uBDF0\uC785\uB2C8\uB2E4.";

    @Autowired
    private AdminDAO adminDAO;

    @Autowired
    private NotificationService notificationService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String updateReportStatus(int reportId, String status) {
        if ("PROCESSED".equalsIgnoreCase(status)) {
            ReportVO report = adminDAO.getReportById(reportId);
            if (report == null) return "fail";

            if ("REVIEW".equalsIgnoreCase(report.getTargetType())) {
                int blindResult = adminDAO.blindReview(report.getTargetId(), BLIND_REVIEW_MESSAGE);
                if (blindResult <= 0) return "fail";
            }
        }

        int result = adminDAO.updateReportStatus(reportId, status);
        if (result <= 0) return "fail";

        // 신고 처리 결과 알림 생성 (PROCESSED / REJECTED 모두 신고자에게 통지)
        // best-effort: NotificationService 내부에서 예외 삼킴 + REQUIRES_NEW 트랜잭션
        notificationService.createReportResultNotification(reportId, status);

        return "ok";
    }
}
