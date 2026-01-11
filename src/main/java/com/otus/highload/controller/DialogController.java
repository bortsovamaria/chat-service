package com.otus.highload.controller;

import com.otus.highload.model.Message;
import com.otus.highload.model.SendMessageRequest;
import com.otus.highload.service.DialogService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/v0/api/dialog")
public class DialogController {

    private final DialogService dialogService;

    @PostMapping("/{userId}")
    public void send(@PathVariable String userId, @RequestBody SendMessageRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String fromUserId = ((String) auth.getPrincipal());
        dialogService.sendMessage(fromUserId, userId, request.getText());
    }

    @GetMapping("/{userId}")
    public List<Message> getDialog(@PathVariable String userId) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String fromUserId = ((String) auth.getPrincipal());
        return dialogService.getDialog(fromUserId, userId);
    }

}
