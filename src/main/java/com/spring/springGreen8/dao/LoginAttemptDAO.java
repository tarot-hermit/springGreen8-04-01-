package com.spring.springGreen8.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.LoginAttemptVO;

@Mapper
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
