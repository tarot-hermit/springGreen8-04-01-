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
        for (int i = 0; i < 6; i++) {
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
                "<div style='margin:0;padding:32px 0;background-color:#f6f6f7;'>"
                + "  <div style='max-width:560px;margin:0 auto;padding:0 16px;'>"
                + "    <div style='background-color:#ffffff;border:1px solid #ececec;border-radius:28px;overflow:hidden;box-shadow:0 18px 40px rgba(0,0,0,0.08);'>"
                + "      <div style='padding:32px;background:linear-gradient(135deg,#fff0f5 0%,#ffffff 60%,#fff7fa 100%);border-bottom:1px solid #f3f4f6;'>"
                + "        <div style='display:inline-block;padding:8px 14px;border-radius:999px;background:#fff0f5;border:1px solid #ffd2df;color:#ff2f6e;font-size:12px;font-weight:700;letter-spacing:1.2px;'>SPRINGGREEN8</div>"
                + "        <div style='margin-top:16px;font-size:30px;font-weight:800;line-height:1.25;color:#111827;'>이메일 인증 코드</div>"
                + "        <div style='margin-top:10px;font-size:14px;line-height:1.7;color:#6b7280;'>계정 확인을 위해 아래 인증 코드를 입력해주세요.</div>"
                + "      </div>"
                + "      <div style='padding:32px;'>"
                + "        <div style='font-size:15px;line-height:1.8;color:#374151;'>안녕하세요. SpringGreen8 인증 메일입니다.<br>아래 6자리 인증 코드를 입력하면 이메일 인증이 완료됩니다.</div>"
                + "        <div style='margin:28px 0;padding:24px 20px;border:1px solid #ffd2df;border-radius:20px;background:#fff0f5;text-align:center;'>"
                + "          <div style='font-size:12px;font-weight:800;letter-spacing:1.4px;color:#ff2f6e;'>VERIFICATION CODE</div>"
                + "          <div style='margin-top:12px;font-size:34px;font-weight:800;letter-spacing:10px;color:#111827;font-family:Verdana,Arial,sans-serif;'>" + code + "</div>"
                + "        </div>"
                + "        <div style='padding:16px 18px;border-radius:16px;background-color:#f8fafc;border:1px solid #eef0f3;font-size:13px;line-height:1.7;color:#6b7280;'>인증 코드는 5분 동안 유효합니다.<br>본인이 요청하지 않았다면 이 메일은 무시하셔도 됩니다.</div>"
                + "      </div>"
                + "    </div>"
                + "    <div style='padding:16px 4px 0;text-align:center;font-size:12px;color:#9ca3af;'>SpringGreen8</div>"
                + "  </div>"
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
