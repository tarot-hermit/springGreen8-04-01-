package com.spring.springGreen8.service;

import java.util.List;
import com.spring.springGreen8.vo.WatchedVO;

public interface WatchedService {

    // 봤어요 토글 (있으면 취소, 없으면 추가) → "added" | "removed" 반환
    String toggleWatched(String mid, int movieId);

    // 봤어요 여부 확인
    boolean isWatched(String mid, int movieId);

    // 내 봤어요 목록
    List<WatchedVO> getMyWatched(String mid);
}
