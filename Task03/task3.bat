#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Составить список фильмов, имеющих хотя бы одну оценку. Список фильмов отсортировать по году выпуска и по названиям. В списке оставить первые 10 фильмов."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT movies.title, substr(movies.title, length(movies.title) - 4, 4) AS year FROM movies JOIN ratings ON movies.movieId = ratings.movieId ORDER BY 2 ASC, movies.title ASC LIMIT 10;"
echo ""

echo "2. Вывести список всех пользователей, фамилии (не имена!) которых начинаются на букву 'А'. Полученный список отсортировать по дате регистрации. В списке оставить первых 5 пользователей."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT name, register_date FROM users WHERE name LIKE '% A%' ORDER BY register_date ASC LIMIT 5;"
echo ""

echo "3. Написать запрос, возвращающий информацию о рейтингах в более читаемом формате: имя и фамилия эксперта, название фильма, год выпуска, оценка и дата оценки в формате ГГГГ-ММ-ДД. Отсортировать данные по имени эксперта, затем названию фильма и оценке. В списке оставить первые 50 записей."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT users.name AS expert, movies.title, substr(movies.title, length(movies.title) - 4, 4) AS year, ratings.rating, strftime('%Y-%m-%d', ratings.timestamp, 'unixepoch') AS rating_date FROM ratings JOIN users ON ratings.userId = users.userId JOIN movies ON ratings.movieId = movies.movieId ORDER BY users.name ASC, movies.title ASC, ratings.rating ASC LIMIT 50;"
echo ""

echo "4. Вывести список фильмов с указанием тегов, которые были им присвоены пользователями. Сортировать по году выпуска, затем по названию фильма, затем по тегу. В списке оставить первые 40 записей."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT movies.title, substr(movies.title, length(movies.title) - 4, 4) AS year, tags.tag FROM movies JOIN tags ON movies.movieId = tags.movieId ORDER BY year ASC, movies.title ASC, tags.tag ASC LIMIT 40;"
echo ""

echo "5. Вывести список самых свежих фильмов. В список должны войти все фильмы последнего года выпуска, имеющиеся в базе данных. Запрос должен быть универсальным, не зависящим от исходных данных."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT title FROM movies WHERE title LIKE '%(' || (SELECT MAX(substr(title, length(title) - 4, 4)) FROM movies WHERE title LIKE '%(%)%' AND substr(title, length(title) - 4, 4) GLOB '[0-9][0-9][0-9][0-9]') || ')%' ORDER BY title ASC;"
echo ""

echo "6. Найти все комедии, выпущенные после 2000 года, которые понравились мужчинам (оценка не ниже 4.5). Для каждого фильма в этом списке вывести название, год выпуска и количество таких оценок. Результат отсортировать по году выпуска и названию фильма."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT movies.title, substr(movies.title, length(movies.title) - 4, 4) AS year, COUNT(*) AS male_ratings FROM movies JOIN ratings ON movies.movieId = ratings.movieId JOIN users ON ratings.userId = users.userId WHERE movies.genres LIKE '%Comedy%' AND users.gender = 'male' AND ratings.rating >= 4.5 AND substr(movies.title, length(movies.title) - 4, 4) > '2000' GROUP BY movies.movieId ORDER BY year ASC, movies.title ASC;"
echo ""

echo "7. Провести анализ занятий (профессий) пользователей - вывести количество пользователей для каждого рода занятий. Найти самую распространенную и самую редкую профессию посетителей сайта."
echo "----------------------------------------------------------------------------------------------------"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) AS user_count FROM users GROUP BY occupation ORDER BY user_count DESC;"
echo ""
echo "Самая популярная профессия:"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) AS user_count FROM users GROUP BY occupation ORDER BY user_count DESC LIMIT 1;"
echo ""
echo "Самая редкая профессия:"
sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) AS user_count FROM users GROUP BY occupation ORDER BY user_count ASC LIMIT 1;"
echo ""