# Task02 — ETL: создание таблиц и загрузка данных

## Что делает проект
Скрипт `make_db_init.py` читает CSV/TXT-файлы из папки `../dataset/`, генерирует SQL-скрипт `db_init.sql`, а затем `sqlite3` создаёт базу данных `movies_rating.db` с четырьмя таблицами: `movies`, `ratings`, `tags`, `users`.

## Требования к окружению
- Python 3.x
- SQLite 3
- Git Bash (входит в Git for Windows)

## Запуск
```bash
bash db_init.bat