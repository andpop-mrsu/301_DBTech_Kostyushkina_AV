import csv
import os

DATASET_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'dataset')
OUTPUT_SQL = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'db_init.sql')


TABLES = [
    {
        'file': 'movies.csv',
        'delimiter': ',',
        'table': 'movies',
        'schema': '''CREATE TABLE movies (
            movieId INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            genres TEXT
        );''',
        'columns': ['movieId', 'title', 'genres']
    },

    {
        'file': 'ratings.csv',
        'delimiter': ',',
        'table': 'ratings',
        'schema': '''CREATE TABLE ratings (
           userId INTEGER NOT NULL,
           movieId INTEGER NOT NULL,
           rating REAL NOT NULL,
           timestamp INTEGER NOT NULL
       );''',
        'columns': ['userId', 'movieId', 'rating', 'timestamp']
    },

    {
        'file': 'tags.csv',
        'delimiter': ',',
        'table': 'tags',
        'schema': '''CREATE TABLE tags (
        userId INTEGER NOT NULL,
        movieId INTEGER NOT NULL,
        tag TEXT,
        timestamp INTEGER NOT NULL
    );''',
        'columns': ['userId', 'movieId', 'tag', 'timestamp']
    },

    {
        'file': 'users.txt',
        'delimiter': '|',
        'table': 'users',
        'schema': '''CREATE TABLE users (
        userId INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        gender TEXT,
        register_date TEXT,
        occupation TEXT
    );''',
        'columns': ['userId', 'name', 'email', 'gender', 'register_date', 'occupation']
    },
]



def escape(value):
    """Преобразует значение в корректную SQL-запись."""
    if value is None or value == '':
        return 'NULL'
    try:
        return str(int(value))
    except ValueError:
        pass
    try:
        return str(float(value))
    except ValueError:
        pass
    return "'" + str(value).replace("'", "''") + "'"



def generate_sql():
    with open(OUTPUT_SQL, 'w', encoding='utf-8') as out:
        out.write('-- Auto-generated SQL script\n')
        out.write('PRAGMA foreign_keys = OFF;\n\n')

        for t in TABLES:
            file_path = os.path.join(DATASET_DIR, t['file'])
            out.write(f'-- Table: {t["table"]}\n')
            out.write(f'DROP TABLE IF EXISTS {t["table"]};\n')
            out.write(t['schema'] + '\n')

            if not os.path.exists(file_path):
                print(f'[WARN] Файл не найден: {file_path}')
                continue

            with open(file_path, 'r', encoding='utf-8') as f:
                reader = csv.reader(f, delimiter=t['delimiter'])
                header = next(reader, None)

                cols = ', '.join(t['columns'])
                for row in reader:
                    if not row:
                        continue
                    values = ', '.join(escape(v) for v in row)
                    out.write(f'INSERT INTO {t["table"]} ({cols}) VALUES ({values});\n')

            out.write('\n')

        out.write('PRAGMA foreign_keys = ON;\n')

    print(f'SQL-скрипт создан: {OUTPUT_SQL}')


if __name__ == '__main__':
    generate_sql()