package com.spring.springGreen8.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.spring.springGreen8.vo.CommentVO;

@Mapper
public interface CommentDAO {
	int insertComment(CommentVO vo);
	List<CommentVO> selectCommentsByReviewNo(int reviewNo);
	CommentVO selectCommentByNo(int commentNo);
	int updateComment(CommentVO vo);
	int deleteComment(CommentVO vo);
	int reassignCommentsToUser(@Param("fromUserNo") int fromUserNo, @Param("toUserNo") int toUserNo);
}
