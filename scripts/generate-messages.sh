#!/bin/bash

# Более простая версия - генерируем SQL прямо в docker exec

set -e

echo "📝 Генерация тестовых сообщений..."

docker exec citus-coordinator bash -c "
psql -U postgres -d dialog << 'SQL'

DO \$\$
DECLARE
    user_ids TEXT[] := ARRAY[
        '377e0671-4beb-4ae0-a0f1-da445f5d41ce',
        'a98766e4-8801-4ad2-8154-1bea061ad90a',
        '139b68c0-177d-480c-b403-84b5ab01706c',
        '3a35919d-da27-434b-885e-449eeac393c4',
        'b7207874-e195-4cdb-9469-675aa09ad473'
    ];
    messages TEXT[] := ARRAY[
        'Привет! Как дела?',
        'Все хорошо, спасибо!',
        'Что нового?',
        'Работаю над проектом',
        'Добрый день!',
        'Привет!',
        'Встречаемся завтра?',
        'Да, в 10 утра',
        'Скоро буду',
        'Спасибо за помощь',
        'Готово ли задание?',
        'Отправьте документы, пожалуйста',
        'Когда будет совещание?',
        'Можем обсудить это позже',
        'Отличная работа!',
        'Нужна ваша консультация',
        'Завтра в офисе?',
        'Отправляю файл',
        'Проверьте, пожалуйста',
        'Договорились'
    ];
    i INTEGER;
    from_idx INTEGER;
    to_idx INTEGER;
    from_user_id TEXT;
    to_user_id TEXT;
    message_text TEXT;
    days_ago INTEGER;
    hours_ago INTEGER;
    minutes_ago INTEGER;
BEGIN
    RAISE NOTICE 'Начинаем вставку тестовых данных...';

    FOR i IN 1..100 LOOP
        -- Выбираем случайного отправителя
        from_idx := 1 + floor(random() * array_length(user_ids, 1))::INTEGER;
        from_user_id := user_ids[from_idx];

        -- Выбираем случайного получателя (не того же самого)
        to_idx := from_idx;
        WHILE to_idx = from_idx LOOP
            to_idx := 1 + floor(random() * array_length(user_ids, 1))::INTEGER;
        END LOOP;
        to_user_id := user_ids[to_idx];

        -- Выбираем случайное сообщение
        message_text := messages[1 + floor(random() * array_length(messages, 1))::INTEGER];

        -- Случайное время (от 1 до 30 дней назад)
        days_ago := floor(random() * 30)::INTEGER;
        hours_ago := floor(random() * 24)::INTEGER;
        minutes_ago := floor(random() * 60)::INTEGER;

        -- Вставляем сообщение
        INSERT INTO messages (id, from_user_id, to_user_id, text, created_at)
        VALUES (
            gen_random_uuid(),
            from_user_id,
            to_user_id,
            message_text,
            NOW() - (days_ago || ' days')::INTERVAL
                   - (hours_ago || ' hours')::INTERVAL
                   - (minutes_ago || ' minutes')::INTERVAL
        );

        -- Выводим прогресс каждые 20 записей
        IF i % 20 = 0 THEN
            RAISE NOTICE 'Вставлено % сообщений...', i;
        END IF;
    END LOOP;

    RAISE NOTICE 'Готово! Вставлено 100 сообщений.';
END \$\$;

SQL
"

echo "✅ Тестовые данные успешно добавлены!"