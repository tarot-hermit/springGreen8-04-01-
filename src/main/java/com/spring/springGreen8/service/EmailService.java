package com.spring.springGreen8.service;

import java.util.Random;

import javax.mail.internet.MimeMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

	@Autowired
	private JavaMailSender mailSender;
	
	public String createCode() {
		Random rand = new Random();
		StringBuilder code = new StringBuilder();
		for (int i =0; i < 6; i++) {
			code.append(rand.nextInt(10));
		}
		return code.toString();
	}
	
	public String sendAuthMail(String toEmail) {
		String code = createCode();
		 try {
	            MimeMessage message = mailSender.createMimeMessage();
	            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
	            helper.setTo(toEmail);
	            helper.setSubject("[SpringGreen8] 이메일 인증 코드");
	            helper.setText(
	                "<div style='font-family:Arial; padding:20px;'>"
	                + "<h2 style='color:#28a745;'>SpringGreen8 이메일 인증</h2>"
	                + "<p>아래 인증 코드를 입력해주세요.</p>"
	                + "<h1 style='letter-spacing:8px; color:#333;'>" + code + "</h1>"
	                + "<p style='color:#999;'>인증 코드는 5분간 유효합니다.</p>"
	                + "</div>",
	                true
	            );
	            mailSender.send(message);
	        } catch (Exception e) {
	            e.printStackTrace();
	            return null;
	        }
	        return code;
	}
}
