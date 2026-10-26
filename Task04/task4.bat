#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

sqlite3 movies_rating.db ".tables"

echo ""
echo "------- ЗАДАНИЕ 1: Пары пользователей -------"
sqlite3 -header -column movies_rating.db "SELECT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r1.movieId = r2.movieId AND r1.userId < r2.userId JOIN users u1 ON r1.userId = u1.userId JOIN users u2 ON r2.userId = u2.userId JOIN movies m ON r1.movieId = m.movieId LIMIT 100;"


echo ""
echo "--- ЗАДАНИЕ 2: 10 самых свежих оценок ---"
sqlite3 -header -column movies_rating.db "SELECT m.title, u.name AS user, r.rating, date(r.timestamp, 'unixepoch') AS date FROM ratings r JOIN movies m ON r.movieId = m.movieId JOIN users u ON r.userId = u.userId ORDER BY r.timestamp DESC LIMIT 10;"


echo ""
echo "--- ЗАДАНИЕ 3: Фильмы с макс. и мин. средним рейтингом ---"
sqlite3 -header -column movies_rating.db "WITH AvgRatings AS (SELECT movieId, AVG(rating) as avg_rating FROM ratings GROUP BY movieId), MinMax AS (SELECT MAX(avg_rating) as max_r, MIN(avg_rating) as min_r FROM AvgRatings), FilteredMovies AS (SELECT m.title, ar.avg_rating, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS movie_year FROM movies m JOIN AvgRatings ar ON m.movieId = ar.movieId WHERE ar.avg_rating = (SELECT max_r FROM MinMax) OR ar.avg_rating = (SELECT min_r FROM MinMax)) SELECT title, ROUND(avg_rating, 2) as avg_rating, CASE WHEN avg_rating = (SELECT max_r FROM MinMax) THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM FilteredMovies ORDER BY movie_year, title;"


echo ""
echo "--- ЗАДАНИЕ 4: Оценки от женщин 2010-2012 ---"
sqlite3 -header -column movies_rating.db "SELECT COUNT(r.rating) AS count_ratings, ROUND(AVG(r.rating), 2) AS avg_rating FROM ratings r JOIN users u ON r.userId = u.userId WHERE u.gender = 'female' AND u.register_date BETWEEN '2010-01-01' AND '2012-12-31';"


echo ""
echo "--- ЗАДАНИЕ 5: Рейтинг фильмов (первые 20) ---"
sqlite3 -header -column movies_rating.db "SELECT m.title, ROUND(AVG(r.rating), 2) AS avg_rating, RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rank, CAST(substr(m.title, -5, 4) AS INTEGER) AS movie_year FROM movies m JOIN ratings r ON m.movieId = r.movieId WHERE CAST(substr(m.title, -5, 4) AS INTEGER) > 1900 GROUP BY m.movieId ORDER BY movie_year, m.title LIMIT 20;"

echo ""
echo "--- ЗАДАНИЕ 6: 10 последних пользователей ---"
sqlite3 -header -column movies_rating.db "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date AS 'Фамилия Имя|Дата регистрации' FROM users ORDER BY register_date DESC LIMIT 10;"


echo ""
echo "--- ЗАДАНИЕ 7: Таблица умножения 1-10 (CTE) ---"
sqlite3 -header -column movies_rating.db "WITH RECURSIVE nums(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM nums WHERE n < 10) SELECT n1.n || 'x' || n2.n || '=' || (n1.n * n2.n) AS multiplication FROM nums n1 CROSS JOIN nums n2 ORDER BY n1.n, n2.n;"

echo ""
echo "--- ЗАДАНИЕ 8: Все жанры (Рекурсивный CTE) ---"
sqlite3 -header -column movies_rating.db "WITH RECURSIVE split(movieId, genre, rest) AS (SELECT movieId, '', genres || '|' FROM movies UNION ALL SELECT movieId, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM split WHERE rest <> '') SELECT DISTINCT TRIM(genre) AS genre FROM split WHERE TRIM(genre) <> '';"