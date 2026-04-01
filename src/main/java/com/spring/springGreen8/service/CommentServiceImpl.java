package com.spring.springGreen8.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.spring.springGreen8.dao.CommentDAO;
import com.spring.springGreen8.vo.CommentVO;

@Service
public class CommentServiceImpl implements CommentService {
	
	@Autowired
	private CommentDAO commentDAO;
	
	@Override
	public int writeComment(CommentVO vo) {
		return commentDAO.insertComment(vo);
	}

	@Override
	public List<CommentVO> getCommentsByReviewNo(int reviewNo) {
		return commentDAO.selectCommentsByReviewNo(reviewNo);
	}

	@Override
	public int updateComment(CommentVO vo) {
		return commentDAO.updateComment(vo);
	}

	@Override
	public int deleteComment(CommentVO vo) {
		return commentDAO.deleteComment(vo);
	}

}
