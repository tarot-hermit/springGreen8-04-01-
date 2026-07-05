package com.spring.springGreen8.vo;

import java.util.Date;
import lombok.Data;

@Data
/**
 * 사용자의 '봤어요' 기록을 담는 값 객체.
 */
public class WatchedVO {
    private int    watchedId;
    private String mid;       // user_id
    private int    movieId;   // TMDB movie id
    private Date   regDate;
    private String title;
    private String posterPath;
}
