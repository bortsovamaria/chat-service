package com.otus.highload.repository;

import com.otus.highload.model.Message;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class MessageRepository {

    private final JdbcTemplate jdbcTemplate;

    public Optional<List<Message>> findDialog(String fromUserId, String toUserId) {
        String sql = """
            SELECT * FROM messages
            WHERE (from_user_id = ? AND to_user_id = ?)
               OR (from_user_id = ? AND to_user_id = ?)
            ORDER BY created_at
            """;
        return Optional.of(jdbcTemplate.query(sql, messageRowMapper, fromUserId, toUserId, toUserId, fromUserId));
    }

    public void addMessage(Message message) {
        String sql = "INSERT INTO messages (id, from_user_id, to_user_id, text, created_at) " +
                "VALUES (?, ?, ?, ?, ?)";
        jdbcTemplate.update(sql,
                message.getId(),
                message.getFromUserId(),
                message.getToUserId(),
                message.getText(),
                message.getCreatedAt());
    }

    private final RowMapper<Message> messageRowMapper = (rs, rowNum) -> {
        Message dialog = new Message();
        dialog.setId(rs.getString("id"));
        dialog.setFromUserId(rs.getString("from_user_id"));
        dialog.setToUserId(rs.getString("to_user_id"));
        dialog.setText(rs.getString("text"));
        dialog.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return dialog;
    };
}
