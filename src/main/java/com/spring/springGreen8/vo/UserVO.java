package com.spring.springGreen8.vo;

import java.util.Date;
import lombok.Data;

@Data
public class UserVO {
    private int userNo;
    private String userId;
    private String userPw;
    private String userName;
    private String userEmail;
    private String userImg;
    private String userBio;
    private String userRole;
    private String userAddr1;
    private String userAddr2;
    private String userZipcode;
    private Date joinDate;
}