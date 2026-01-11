package com.otus.highload.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Message {

    private String id;

    private String fromUserId;

    private String toUserId;

    private String text;

    private LocalDateTime createdAt;
}
