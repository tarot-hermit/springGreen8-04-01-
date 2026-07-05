package com.spring.springGreen8.service;

import java.util.List;
import com.spring.springGreen8.vo.WatchedVO;

/**
 * '봤어요' 기록 서비스 계약.
 * 시청 완료 토글과 사용자별 시청 기록 조회 기능을 정의한다.
 */
public interface WatchedService {

    // 봤어요 토글 (있으면 취소, 없으면 추가) → "added" | "removed" 반환
    String toggleWatched(String mid, int movieId);

    // 봤어요 여부 확인
    boolean isWatched(String mid, int movieId);

    // 내 봤어요 목록
    List<WatchedVO> getMyWatched(String mid);
}
