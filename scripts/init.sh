#!/bin/bash

set -e

echo "Инициализируем кластер"

# Инициализируем кластер
docker exec citus-coordinator bash -c "
psql -U postgres -d dialog << 'SQL'

-- 1. Включение расширения Citus на координаторе
CREATE EXTENSION IF NOT EXISTS citus;

-- 2. Настройка параметров подключения к узлам (ВАЖНО!)
ALTER SYSTEM SET citus.node_conninfo TO 'host=\$1 port=\$2 user=postgres password=postgres dbname=dialog sslmode=prefer';
SELECT pg_reload_conf();

-- 3. Добавление worker узлов с явным указанием пароля
SELECT * FROM master_add_node('citus-worker-1', 5432);
SELECT * FROM master_add_node('citus-worker-2', 5432);
SELECT * FROM master_add_node('citus-worker-3', 5432);

-- 4. Проверка, что узлы добавлены и доступны
SELECT * FROM citus_get_active_worker_nodes();

-- 5. Создание таблицы (выполняется на координаторе, распространится на workers)
-- Убираем PRIMARY KEY constraint из создания таблицы
CREATE TABLE IF NOT EXISTS messages (
     id VARCHAR(255),
     from_user_id VARCHAR(50) NOT NULL,
     to_user_id VARCHAR(50) NOT NULL,
     text VARCHAR(250) NOT NULL,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
 );

-- 6. Шардирование таблицы по from_user_id
SELECT create_distributed_table('messages', 'from_user_id');

-- 7. Добавляем уникальный constraint на id как DISTRIBUTED BY (from_user_id)
ALTER TABLE messages ADD CONSTRAINT messages_pkey PRIMARY KEY (id, from_user_id);

-- 8. Создание индексов
CREATE INDEX idx_messages_from_to ON messages(from_user_id, to_user_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
-- Можно также добавить индекс на id для быстрого поиска
CREATE INDEX idx_messages_id ON messages(id);

SQL
"

echo "Проверяем статус узлов..."
docker exec citus-coordinator psql -U postgres -d dialog -c "SELECT * FROM citus_get_active_worker_nodes();"

echo "🎉 Кластер успешно инициализирован!"