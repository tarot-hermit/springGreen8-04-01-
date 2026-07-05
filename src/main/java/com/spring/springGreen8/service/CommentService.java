package com.spring.springGreen8.service;

import java.util.List;

import com.spring.springGreen8.vo.CommentVO;

/**
 * 댓글 기능의 서비스 계약.
 * 리뷰 댓글/답글 CRUD와 댓글 알림 생성 기능을 정의한다.
 */
public interface CommentService {
	int writeComment(CommentVO vo, String senderUserId);
	List<CommentVO> getCommentsByReviewNo(int reviewNo);
	CommentVO getCommentByNo(int commentNo);
	int updateComment(CommentVO vo);
	int deleteComment(CommentVO vo);

}
