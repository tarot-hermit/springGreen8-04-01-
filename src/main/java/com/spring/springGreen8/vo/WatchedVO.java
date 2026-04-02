package com.spring.springGreen8.vo;

import java.util.Date;
import lombok.Data;

@Data
public class WatchedVO {
    private int    watchedId;
    private String mid;       // user_id
    private int    movieId;   // TMDB movie id
    private Date   regDate;
}
