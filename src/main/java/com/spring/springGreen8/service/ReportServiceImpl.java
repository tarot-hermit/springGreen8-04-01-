package com.spring.springGreen8.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.ReportDAO;
import com.spring.springGreen8.vo.ReportVO;

@Service
@Transactional(readOnly = true)
/**
 * 신고 기능의 비즈니스 로직 구현체.
 * 로그인 사용자 기준으로 신고 대상과 사유를 검증한 뒤 운영 처리 대기 상태로 저장한다.
 */
public class ReportServiceImpl implements ReportService {

    @Autowired
    private ReportDAO reportDAO;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public String createReport(ReportVO vo) {
        if (reportDAO.checkDuplicate(vo.getReporterMid(), vo.getTargetType(), vo.getTargetId()) > 0) {
            return "dup";
        }

        try {
            return reportDAO.insertReport(vo) > 0 ? "ok" : "fail";
        } catch (DuplicateKeyException e) {
            return "dup";
        }
    }
}
