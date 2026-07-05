package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.CommentVO;

@Mapper
/**
 * 리뷰 댓글 DB 접근 인터페이스.
 * 댓글/답글 목록, 작성, 수정, 삭제와 작성자 확인 SQL을 담당한다.
 */
public interface CommentDAO {
	int insertComment(CommentVO vo);
	List<CommentVO> selectCommentsByReviewNo(int reviewNo);
	CommentVO selectCommentByNo(int commentNo);
	int updateComment(CommentVO vo);
	int deleteComment(CommentVO vo);
	int reassignCommentsToUser(@Param("fromUserNo") int fromUserNo, @Param("toUserNo") int toUserNo);
}
