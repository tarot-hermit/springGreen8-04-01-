package com.spring.springGreen8.service;

import com.spring.springGreen8.vo.ReportVO;

/**
 * 신고 기능의 서비스 계약.
 * 신고 사유 검증, 중복 신고 확인, 신고 저장 기능을 정의한다.
 */
public interface ReportService {

    String createReport(ReportVO vo);
}
