package com.spring.springGreen8.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.LoginAttemptVO;

@Mapper
/**
 * 로그인 실패 이력 DB 접근 인터페이스.
 * 계정 잠금 판단에 필요한 실패 횟수와 잠금 해제 시각을 저장/조회한다.
 */
public interface LoginAttemptDAO {

    int ensureAttemptRow(LoginAttemptVO vo);

    LoginAttemptVO selectAttempt(@Param("userId") String userId,
                                 @Param("clientIp") String clientIp);

    LoginAttemptVO selectAttemptForUpdate(@Param("userId") String userId,
                                          @Param("clientIp") String clientIp);

    int updateAttempt(LoginAttemptVO vo);

    int deleteAttempt(@Param("userId") String userId,
                      @Param("clientIp") String clientIp);

    int deleteExpiredAttempts();

    int deleteAttemptsByUserId(@Param("userId") String userId);
}
