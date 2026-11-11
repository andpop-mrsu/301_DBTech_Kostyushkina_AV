#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Для каждого фильма выведите его название, год выпуска и средний рейтинг..."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT m.title, SUBSTR(m.title, INSTR(m.title, '(') + 1, 4) AS release_year, ROUND(AVG(r.rating), 2) AS avg_rating, RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rank_by_avg_rating FROM movies m JOIN ratings r ON m.movieId = r.movieId GROUP BY m.movieId ORDER BY rank_by_avg_rating ASC LIMIT 10;"
echo " "

echo "2. Жанры, средний рейтинг и ранг жанра..."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(movieId, genre, rest) AS (SELECT movieId, SUBSTR(genres, 1, INSTR(genres || '|', '|') - 1), SUBSTR(genres, INSTR(genres || '|', '|') + 1) FROM movies UNION ALL SELECT movieId, SUBSTR(rest, 1, INSTR(rest || '|', '|') - 1), SUBSTR(rest, INSTR(rest || '|', '|') + 1) FROM split_genres WHERE rest <> ''), genre_ratings AS (SELECT sg.genre, AVG(r.rating) AS avg_rating FROM split_genres sg JOIN ratings r ON sg.movieId = r.movieId WHERE sg.genre <> '' GROUP BY sg.genre) SELECT genre, ROUND(avg_rating, 2) AS avg_rating, RANK() OVER (ORDER BY avg_rating DESC) AS genre_rank FROM genre_ratings;"
echo " "

echo "3. Посчитайте количество фильмов в каждом жанре..."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(movieId, genre, rest) AS (SELECT movieId, SUBSTR(genres, 1, INSTR(genres || '|', '|') - 1), SUBSTR(genres, INSTR(genres || '|', '|') + 1) FROM movies UNION ALL SELECT movieId, SUBSTR(rest, 1, INSTR(rest || '|', '|') - 1), SUBSTR(rest, INSTR(rest || '|', '|') + 1) FROM split_genres WHERE rest <> '') SELECT genre, COUNT(movieId) AS movie_count FROM split_genres WHERE genre <> '' GROUP BY genre ORDER BY movie_count DESC;"
echo " "


echo "4. Найдите жанры, в которых чаще всего оставляют теги. Выведите genre, tag_count и tag_share (в процентах)..."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(movieId, genre, rest) AS (SELECT movieId, SUBSTR(genres, 1, INSTR(genres || '|', '|') - 1), SUBSTR(genres, INSTR(genres || '|', '|') + 1) FROM movies UNION ALL SELECT movieId, SUBSTR(rest, 1, INSTR(rest || '|', '|') - 1), SUBSTR(rest, INSTR(rest || '|', '|') + 1) FROM split_genres WHERE rest <> ''), genre_tags AS (SELECT sg.genre, COUNT(*) AS tag_count FROM split_genres sg JOIN tags t ON sg.movieId = t.movieId WHERE sg.genre <> '' GROUP BY sg.genre), total_tags AS (SELECT COUNT(*) AS total FROM tags) SELECT gt.genre, gt.tag_count, ROUND((CAST(gt.tag_count AS REAL) / tt.total) * 100, 2) AS tag_share FROM genre_tags gt CROSS JOIN total_tags tt ORDER BY gt.tag_count DESC;"
echo " "


echo "5. Топ-10 пользователей: количество оценок, средний рейтинг, даты первой и последней оценки."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT userId, COUNT(rating) AS rating_count, ROUND(AVG(rating), 2) AS avg_rating, datetime(MIN(timestamp), 'unixepoch') AS first_rating_date, datetime(MAX(timestamp), 'unixepoch') AS last_rating_date FROM ratings GROUP BY userId ORDER BY rating_count DESC LIMIT 10;"
echo " "


echo "6. Сегментация пользователей по типу поведения (Комментаторы, Оценщики, Активные, Пассивные)."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH user_stats AS (SELECT u.userId, (SELECT COUNT(*) FROM ratings r WHERE r.userId = u.userId) AS rating_cnt, (SELECT COUNT(*) FROM tags t WHERE t.userId = u.userId) AS tag_cnt FROM users u) SELECT userId, rating_cnt, tag_cnt, CASE WHEN tag_cnt > rating_cnt THEN 'Комментаторы' WHEN rating_cnt > tag_cnt THEN 'Оценщики' WHEN rating_cnt >= 10 AND tag_cnt >= 10 THEN 'Активные' WHEN rating_cnt < 5 AND tag_cnt < 5 THEN 'Пассивные' ELSE 'Другие' END AS behavior_category FROM user_stats;"
echo " "


echo "7. Для каждого пользователя: имя и последний оцененный фильм."
echo "--------------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "WITH last_ratings AS (SELECT userId, movieId, timestamp, ROW_NUMBER() OVER(PARTITION BY userId ORDER BY timestamp DESC) AS rn FROM ratings) SELECT u.userId, u.name, m.title AS last_rated_movie_title, datetime(lr.timestamp, 'unixepoch') AS last_rating_timestamp FROM users u LEFT JOIN last_ratings lr ON u.userId = lr.userId AND lr.rn = 1 LEFT JOIN movies m ON lr.movieId = m.movieId;"
echo " "