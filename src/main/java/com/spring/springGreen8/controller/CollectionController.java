package com.spring.springGreen8.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.spring.springGreen8.service.CollectionService;
import com.spring.springGreen8.vo.CollectionVO;
import com.spring.springGreen8.vo.UserVO;

/**
 * 사용자 컬렉션 기능을 처리하는 컨트롤러.
 * 컬렉션 생성/수정/삭제, 공개 여부 변경, 콘텐츠 추가/제거 요청을 담당한다.
 */
@Controller
@RequestMapping("/collection")
public class CollectionController {

    @Autowired
    private CollectionService collectionService;

    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public String myList(HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/user/login";
        model.addAttribute("collections", collectionService.getMyCollections(loginUser.getUserId()));
        return "collection/list";
    }

    @RequestMapping(value = "/public", method = RequestMethod.GET)
    public String publicList(Model model) {
        model.addAttribute("collections", collectionService.getPublicCollections());
        return "collection/public";
    }

    @RequestMapping(value = "/detail/{collectionId}", method = RequestMethod.GET)
    public String detail(@PathVariable("collectionId") int collectionId, HttpSession session, Model model) {
        CollectionVO collection = collectionService.getCollectionById(collectionId);
        if (collection == null) return "redirect:/collection/public";

        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (collection.getIsPublic() == 0) {
            if (loginUser == null || !loginUser.getUserId().equals(collection.getMid())) {
                return "redirect:/";
            }
        }

        List<Integer> movieIds = collectionService.getMovieIds(collectionId);
        model.addAttribute("collection", collection);
        model.addAttribute("movieIds", movieIds);
        return "collection/detail";
    }

    @RequestMapping(value = "/create", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> create(@RequestParam("title") String title,
                                      @RequestParam(value = "description", defaultValue = "") String description,
                                      @RequestParam(value = "isPublic", defaultValue = "1") int isPublic,
                                      HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "login");
            return result;
        }

        String normalizedTitle = title == null ? "" : title.trim();
        String normalizedDescription = description == null ? "" : description.trim();
        if (normalizedTitle.isEmpty() || normalizedTitle.length() > 100) {
            result.put("status", "fail");
            result.put("msg", "제목은 1자 이상 100자 이하로 입력해주세요.");
            return result;
        }
        if (normalizedDescription.length() > 500) {
            result.put("status", "fail");
            result.put("msg", "설명은 500자 이하로 입력해주세요.");
            return result;
        }

        CollectionVO vo = new CollectionVO();
        vo.setMid(loginUser.getUserId());
        vo.setTitle(normalizedTitle);
        vo.setDescription(normalizedDescription);
        vo.setIsPublic(isPublic == 0 ? 0 : 1);

        int res = collectionService.createCollection(vo);
        if (res > 0) {
            result.put("status", "ok");
            result.put("collectionId", vo.getCollectionId());
        }
        else {
            result.put("status", "fail");
        }
        return result;
    }

    @RequestMapping(value = "/update", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> update(@RequestParam("collectionId") int collectionId,
                                      @RequestParam("title") String title,
                                      @RequestParam(value = "description", defaultValue = "") String description,
                                      @RequestParam(value = "isPublic", defaultValue = "1") int isPublic,
                                      HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "login");
            return result;
        }

        String normalizedTitle = title == null ? "" : title.trim();
        String normalizedDescription = description == null ? "" : description.trim();
        if (normalizedTitle.isEmpty() || normalizedTitle.length() > 100) {
            result.put("status", "fail");
            result.put("msg", "제목은 1자 이상 100자 이하로 입력해주세요.");
            return result;
        }
        if (normalizedDescription.length() > 500) {
            result.put("status", "fail");
            result.put("msg", "설명은 500자 이하로 입력해주세요.");
            return result;
        }

        // 소유권 검증 — UPDATE SQL의 mid 조건이 1차 방어이지만,
        // 컨트롤러 레벨에서도 명시적으로 확인해 권한 없는 접근을 분명히 거절한다.
        CollectionVO target = collectionService.getCollectionById(collectionId);
        if (target == null || !loginUser.getUserId().equals(target.getMid())) {
            result.put("status", "forbidden");
            result.put("msg", "수정 권한이 없습니다.");
            return result;
        }

        CollectionVO vo = new CollectionVO();
        vo.setCollectionId(collectionId);
        vo.setMid(loginUser.getUserId());
        vo.setTitle(normalizedTitle);
        vo.setDescription(normalizedDescription);
        vo.setIsPublic(isPublic == 0 ? 0 : 1);

        int res = collectionService.updateCollection(vo);
        result.put("status", res > 0 ? "ok" : "fail");
        return result;
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> delete(@RequestParam("collectionId") int collectionId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "login");
            return result;
        }

        int res = collectionService.deleteCollection(collectionId, loginUser.getUserId());
        result.put("status", res > 0 ? "ok" : "fail");
        return result;
    }

    @RequestMapping(value = "/movie/toggle", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> toggleMovie(@RequestParam("collectionId") int collectionId,
                                           @RequestParam("movieId") int movieId,
                                           HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) {
            result.put("status", "login");
            return result;
        }

        CollectionVO col = collectionService.getCollectionById(collectionId);
        if (col == null || !col.getMid().equals(loginUser.getUserId())) {
            result.put("status", "fail");
            return result;
        }

        String action = collectionService.toggleCollectionMovie(collectionId, movieId);
        result.put("status", action);
        return result;
    }

    @RequestMapping(value = "/my", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<CollectionVO> myCollections(@RequestParam(value = "movieId", required = false) Integer movieId,
                                            HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return List.of();
        return collectionService.getMyCollections(loginUser.getUserId(), movieId);
    }
}
