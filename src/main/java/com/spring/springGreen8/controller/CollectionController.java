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

@Controller
@RequestMapping("/collection")
public class CollectionController {

    @Autowired
    private CollectionService collectionService;

    // ── 내 컬렉션 목록 ────────────────────────────────────────────
    @RequestMapping(value = "/list", method = RequestMethod.GET)
    public String myList(HttpSession session, Model model) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return "redirect:/user/login";
        model.addAttribute("collections",
            collectionService.getMyCollections(loginUser.getUserId()));
        return "collection/list";
    }

    // ── 공개 컬렉션 탐색 ──────────────────────────────────────────
    @RequestMapping(value = "/public", method = RequestMethod.GET)
    public String publicList(Model model) {
        model.addAttribute("collections", collectionService.getPublicCollections());
        return "collection/public";
    }

    // ── 컬렉션 상세 ───────────────────────────────────────────────
    @RequestMapping(value = "/detail/{collectionId}", method = RequestMethod.GET)
    public String detail(@PathVariable int collectionId,
                         HttpSession session, Model model) {
        CollectionVO collection = collectionService.getCollectionById(collectionId);
        if (collection == null) return "redirect:/collection/public";

        // 비공개 컬렉션 — 본인만 접근 가능
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (collection.getIsPublic() == 0) {
            if (loginUser == null ||
                !loginUser.getUserId().equals(collection.getMid())) {
                return "redirect:/";
            }
        }

        List<Integer> movieIds = collectionService.getMovieIds(collectionId);
        model.addAttribute("collection", collection);
        model.addAttribute("movieIds",   movieIds);
        return "collection/detail";
    }

    // ── 컬렉션 생성 (Ajax) ────────────────────────────────────────
    @RequestMapping(value = "/create", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> create(@RequestParam String title,
                                       @RequestParam(defaultValue = "") String description,
                                       @RequestParam(defaultValue = "1") int isPublic,
                                       HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("status", "login"); return result; }

        if (title == null || title.trim().isEmpty() || title.length() > 100) {
            result.put("status", "fail");
            result.put("msg", "제목은 1자 이상 100자 이하로 입력해주세요.");
            return result;
        }

        CollectionVO vo = new CollectionVO();
        vo.setMid(loginUser.getUserId());
        vo.setTitle(title.trim());
        vo.setDescription(description.trim());
        vo.setIsPublic(isPublic);

        int res = collectionService.createCollection(vo);
        if (res > 0) {
            result.put("status", "ok");
            result.put("collectionId", vo.getCollectionId());
        } else {
            result.put("status", "fail");
        }
        return result;
    }

    // ── 컬렉션 수정 (Ajax) ────────────────────────────────────────
    @RequestMapping(value = "/update", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> update(@RequestParam int    collectionId,
                                       @RequestParam String title,
                                       @RequestParam(defaultValue = "") String description,
                                       @RequestParam(defaultValue = "1") int isPublic,
                                       HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("status", "login"); return result; }
        if (title == null || title.trim().isEmpty() || title.length() > 100) {
            result.put("status", "fail");
            result.put("msg", "제목은 1자 이상 100자 이하로 입력해주세요.");
            return result;
        }

        CollectionVO vo = new CollectionVO();
        vo.setCollectionId(collectionId);
        vo.setMid(loginUser.getUserId());
        vo.setTitle(title.trim());
        vo.setDescription(description == null ? "" : description.trim());
        vo.setIsPublic(isPublic);

        int res = collectionService.updateCollection(vo);
        result.put("status", res > 0 ? "ok" : "fail");
        return result;
    }

    // ── 컬렉션 삭제 (Ajax) ────────────────────────────────────────
    @RequestMapping(value = "/delete", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> delete(@RequestParam int collectionId,
                                       HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("status", "login"); return result; }

        int res = collectionService.deleteCollection(collectionId, loginUser.getUserId());
        result.put("status", res > 0 ? "ok" : "fail");
        return result;
    }

    // ── 영화 추가/제거 토글 (Ajax) ────────────────────────────────
    @RequestMapping(value = "/movie/toggle", method = RequestMethod.POST,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public Map<String, Object> toggleMovie(@RequestParam int collectionId,
                                            @RequestParam int movieId,
                                            HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) { result.put("status", "login"); return result; }

        // 본인 컬렉션인지 확인
        CollectionVO col = collectionService.getCollectionById(collectionId);
        if (col == null || !col.getMid().equals(loginUser.getUserId())) {
            result.put("status", "fail");
            return result;
        }

        String action = collectionService.toggleCollectionMovie(collectionId, movieId);
        result.put("status", action);  // "added" | "removed"
        return result;
    }

    // ── 내 컬렉션 목록 조회 (영화 추가 모달용 Ajax) ───────────────
    @RequestMapping(value = "/my", method = RequestMethod.GET,
                    produces = "application/json; charset=utf-8")
    @ResponseBody
    public List<CollectionVO> myCollections(HttpSession session) {
        UserVO loginUser = (UserVO) session.getAttribute("loginUser");
        if (loginUser == null) return List.of();
        return collectionService.getMyCollections(loginUser.getUserId());
    }
}
