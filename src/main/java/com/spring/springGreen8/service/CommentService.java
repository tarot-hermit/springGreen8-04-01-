package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.CommentVO;

public interface CommentService {
	int writeComment(CommentVO vo);
	List<CommentVO> getCommentsByReviewNo(int reviewNo);
	int updateComment(CommentVO vo);
	int deleteComment(CommentVO vo);

}
