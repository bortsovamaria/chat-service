package com.otus.highload.service;

import com.otus.highload.model.Message;
import com.otus.highload.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DialogService {

    private final MessageRepository messageRepository;

    public void sendMessage(String fromUserId, String toUserId, String text) {
        Message message = new Message();
        message.setId(UUID.randomUUID().toString());
        message.setFromUserId(fromUserId);
        message.setToUserId(toUserId);
        message.setText(text);
        message.setCreatedAt(LocalDateTime.now());

        messageRepository.addMessage(message);
    }

    public List<Message> getDialog(String fromUserId, String toUserId) {
        return messageRepository.findDialog(fromUserId, toUserId).orElseThrow();
    }
}
