-- liquibase formatted sql

-- changeset author:1

-- 1. Включение расширения Citus на координаторе
CREATE EXTENSION IF NOT EXISTS citus;

-- 2. Добавление worker узлов (выполняется на координаторе)
SELECT * FROM master_add_node('citus-worker-1', 5432);
SELECT * FROM master_add_node('citus-worker-2', 5432);
SELECT * FROM master_add_node('citus-worker-3', 5432);

-- 3. Создание таблицы (выполняется на координаторе, распространится на workers)
CREATE TABLE IF NOT EXISTS messages (
     id VARCHAR(255) PRIMARY KEY,
     from_user_id VARCHAR(50) NOT NULL,
     to_user_id VARCHAR(50) NOT NULL,
     text VARCHAR(250) NOT NULL,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
 );

-- 4. Шардирование таблицы по from_user_id
SELECT create_distributed_table('messages', 'from_user_id');

-- 5. Создание индексов
CREATE INDEX idx_messages_from_to ON messages(from_user_id, to_user_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
