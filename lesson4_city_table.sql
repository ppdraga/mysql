

-- 1. Повторить все действия по доработке БД vk.




-- 2. Заполнить новые таблицы.

CREATE TABLE IF NOT EXISTS cities (id SERIAL PRIMARY KEY, name VARCHAR(64));

INSERT INTO cities (name) VALUES 
	('Moscow'),
	('London'),
	('New York'),
	('Berlin'),
    ('Paris'),
    ('Ostin'),
	('Boston'),
	('Houston'),
	('Humburg'),
    ('Philadelphia'),
    ('Richmond'),
	('Indianapolis'),
	('Chicago'),
	('Atlanta'),
    ('Memphis'),
    ('St. Louis'),
	('Orlando'),
	('Tampa'),
	('Jacksonville'),
    ('Miami'),
    ('Denver'),
	('Phoenix'),
	('Portland'),
	('Sacramento'),
    ('Seatlle');

SELECT * FROM cities;


CREATE TABLE IF NOT EXISTS countries (id SERIAL PRIMARY KEY, name VARCHAR(64));

INSERT INTO countries (name) VALUES 
	('Russia'),
	('USA'),
	('Germany'),
	('Great Britain'),
    ('France');

SELECT * FROM countries;


-- 3. Повторить все действия CRUD.

SELECT * FROM profiles LIMIT 15;
DESC profiles;
UPDATE profiles SET city=NULL;
UPDATE profiles SET country=NULL;
ALTER TABLE profiles CHANGE COLUMN city city_id BIGINT UNSIGNED;
ALTER TABLE profiles CHANGE COLUMN country country_id BIGINT UNSIGNED;

UPDATE profiles SET 
  city_id = FLOOR(1 + RAND() * 25),
  country_id = FLOOR(1 + RAND() * 5);


-- 4. Подобрать сервис-образец для курсовой работы.

-- Сервис складского учета, будут таблицы для приходных накладных, расходных накладных, таблица движения остатков, товары и несколько вспомогательных к ним




