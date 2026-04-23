package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.CommentVO;

public interface CommentService {
	int writeComment(CommentVO vo, String senderUserId);
	List<CommentVO> getCommentsByReviewNo(int reviewNo);
	CommentVO getCommentByNo(int commentNo);
	int updateComment(CommentVO vo);
	int deleteComment(CommentVO vo);

}
