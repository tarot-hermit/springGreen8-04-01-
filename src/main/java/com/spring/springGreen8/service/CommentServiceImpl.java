package com.spring.springGreen8.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.spring.springGreen8.dao.CommentDAO;
import com.spring.springGreen8.vo.CommentVO;

@Service
@Transactional(readOnly = true)
public class CommentServiceImpl implements CommentService {

	@Autowired
	private CommentDAO commentDAO;

	@Autowired
	private NotificationService notificationService;

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int writeComment(CommentVO vo, String senderUserId) {
		CommentVO parent = null;

		if (vo.getParentId() != null && vo.getParentId() <= 0) {
			vo.setParentId(null);
		}

		if (vo.getParentId() != null) {
			parent = commentDAO.selectCommentByNo(vo.getParentId());
			if (parent == null || parent.getReviewNo() != vo.getReviewNo()) {
				return 0;
			}

			// 대댓글의 대댓글은 허용하지 않음 → 최상위 부모로 재연결
			if (parent.getParentId() != null) {
				vo.setParentId(parent.getParentId());
				parent = commentDAO.selectCommentByNo(parent.getParentId());
				if (parent == null || parent.getReviewNo() != vo.getReviewNo()) {
					return 0;
				}
			}
		}

		int result = commentDAO.insertComment(vo);
		if (result <= 0) return result;

		if (vo.getParentId() == null) {
			notificationService.createCommentNotification(vo, senderUserId);
		} else if (parent != null) {
			notificationService.createReplyNotification(vo, parent, senderUserId);
		}
		return result;
	}

	@Override
	public List<CommentVO> getCommentsByReviewNo(int reviewNo) {
		return commentDAO.selectCommentsByReviewNo(reviewNo);
	}

	@Override
	public CommentVO getCommentByNo(int commentNo) {
		return commentDAO.selectCommentByNo(commentNo);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int updateComment(CommentVO vo) {
		return commentDAO.updateComment(vo);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int deleteComment(CommentVO vo) {
		return commentDAO.deleteComment(vo);
	}
}
