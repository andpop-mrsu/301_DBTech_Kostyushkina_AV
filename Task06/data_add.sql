PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- 1. Пять новых пользователей
INSERT INTO users (full_name, email, gender, registration_date) VALUES ('Костюшкина Алена', 'my.email@example.com', 'female', date('now'));
INSERT INTO users (full_name, email, gender, registration_date) VALUES ('Крылов Роман', 'neighbor1@example.com', 'male', date('now'));
INSERT INTO users (full_name, email, gender, registration_date) VALUES ('Мунтян Ярослав', 'neighbor2@example.com', 'male', date('now'));
INSERT INTO users (full_name, email, gender, registration_date) VALUES ('Романов Владислав', 'neighbor3@example.com', 'male', date('now'));
INSERT INTO users (full_name, email, gender, registration_date) VALUES ('Салагаев Роман', 'neighbor4@example.com', 'male', date('now'));

-- 2. Три новых фильма разных жанров
INSERT INTO movies (title, release_year) VALUES ('My Sci-Fi Movie', 2024);
INSERT INTO movies (title, release_year) VALUES ('My Comedy Movie', 2023);
INSERT INTO movies (title, release_year) VALUES ('My Drama Movie', 2022);

-- Связь с жанрами
INSERT INTO movie_genres (movie_id, genre_id) VALUES 
    ((SELECT movie_id FROM movies WHERE title = 'My Sci-Fi Movie' LIMIT 1), 
     (SELECT genre_id FROM genres WHERE name = 'Sci-Fi' LIMIT 1));
INSERT INTO movie_genres (movie_id, genre_id) VALUES 
    ((SELECT movie_id FROM movies WHERE title = 'My Comedy Movie' LIMIT 1), 
     (SELECT genre_id FROM genres WHERE name = 'Comedy' LIMIT 1));
INSERT INTO movie_genres (movie_id, genre_id) VALUES 
    ((SELECT movie_id FROM movies WHERE title = 'My Drama Movie' LIMIT 1), 
     (SELECT genre_id FROM genres WHERE name = 'Drama' LIMIT 1));

-- 3. Три отзыва от себя
INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES 
    ((SELECT user_id FROM users WHERE email = 'my.email@example.com' LIMIT 1),
     (SELECT movie_id FROM movies WHERE title = 'My Sci-Fi Movie' LIMIT 1), 5.0, strftime('%s', 'now'));
INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES 
    ((SELECT user_id FROM users WHERE email = 'my.email@example.com' LIMIT 1),
     (SELECT movie_id FROM movies WHERE title = 'My Comedy Movie' LIMIT 1), 4.5, strftime('%s', 'now'));
INSERT INTO ratings (user_id, movie_id, rating, timestamp) VALUES 
    ((SELECT user_id FROM users WHERE email = 'my.email@example.com' LIMIT 1),
     (SELECT movie_id FROM movies WHERE title = 'My Drama Movie' LIMIT 1), 4.0, strftime('%s', 'now'));

COMMIT;
