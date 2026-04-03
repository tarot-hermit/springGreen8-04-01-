package com.spring.springGreen8.service;

import org.apache.commons.codec.digest.DigestUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.springGreen8.dao.UserDAO;
import com.spring.springGreen8.vo.UserVO;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserDAO userDAO;

    @Override
    public int join(UserVO vo) {
        vo.setUserPw(DigestUtils.sha256Hex(vo.getUserPw()));
        return userDAO.insertUser(vo);
    }

    @Override
    public int checkId(String userId) {
        return userDAO.checkId(userId);
    }

    @Override
    public UserVO login(String userId, String userPw) {
        UserVO user = userDAO.selectUserById(userId);
        if (user == null) {
            return null;
        }

        String encPw = DigestUtils.sha256Hex(userPw);
        return encPw.equals(user.getUserPw()) ? user : null;
    }

    @Override
    public UserVO getUser(int userNo) {
        return userDAO.selectUserByNo(userNo);
    }

    @Override
    public int updateUser(UserVO vo) {
        return userDAO.updateUser(vo);
    }

    @Override
    public int updateUserImg(UserVO vo) {
        return userDAO.updateUserImg(vo);
    }

    @Override
    public int checkEmail(String userEmail) {
        return userDAO.checkEmail(userEmail);
    }

    @Override
    public UserVO getUserByIdAndEmail(String userId, String userEmail) {
        return userDAO.selectUserByIdAndEmail(userId, userEmail);
    }

    @Override
    public UserVO getUserByUserId(String userId) {
        return userDAO.selectUserById(userId);
    }

    @Override
    public int updatePw(UserVO vo) {
        return userDAO.updatePw(vo);
    }

    @Override
    public UserVO getUserByEmail(String userEmail) {
        return userDAO.selectUserByEmail(userEmail);
    }
}
