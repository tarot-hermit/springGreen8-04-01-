package com.spring.springGreen8.controller;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalViewOptionsAdvice {

    @ModelAttribute("countryOptions")
    public Map<String, String> countryOptions() {
        Map<String, String> options = new LinkedHashMap<>();
        options.put("ALL", "전체 국가");
        options.put("KR", "한국");
        options.put("JP", "일본");
        options.put("US", "미국");
        options.put("GB", "영국");
        options.put("FR", "프랑스");
        options.put("DE", "독일");
        options.put("ES", "스페인");
        options.put("IT", "이탈리아");
        options.put("CN", "중국");
        options.put("TW", "대만");
        options.put("HK", "홍콩");
        options.put("IN", "인도");
        options.put("CA", "캐나다");
        options.put("AU", "호주");
        return options;
    }
}
