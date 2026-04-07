package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.spring.springGreen8.vo.CommentVO;

@Mapper
public interface CommentDAO {
	// 댓글 등록
	int insertComment(CommentVO vo);
	// 리뷰별 댓글 목록
	List<CommentVO> selectCommentsByReviewNo(int reviewNo);
	// 댓글 수정
	int updateComment(CommentVO vo);
	// 댓글 삭제
	int deleteComment(CommentVO vo);

}
