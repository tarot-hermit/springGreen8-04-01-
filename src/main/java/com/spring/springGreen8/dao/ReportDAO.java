package com.spring.springGreen8.dao;

import java.util.List;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import com.spring.springGreen8.vo.ReportVO;

@Mapper
public interface ReportDAO {

    // 신고 등록
    int insertReport(ReportVO vo);

    // 중복 신고 여부 확인
    int checkDuplicate(@Param("reporterMid") String reporterMid,
                       @Param("targetType")  String targetType,
                       @Param("targetId")    int targetId);

    // 신고 목록 전체 (관리자용)
    List<ReportVO> selectAllReports();

    // 신고 상태 변경
    int updateStatus(@Param("reportId") int reportId,
                     @Param("status")   String status);
}
