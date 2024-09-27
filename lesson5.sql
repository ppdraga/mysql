-- Практическое задание по теме «Операторы, фильтрация, сортировка и ограничение»

-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. 
--    Заполните их текущими датой и временем.

ALTER TABLE users ADD COLUMN created_at VARCHAR(64);
ALTER TABLE users ADD COLUMN updated_at VARCHAR(64);

UPDATE users SET created_at = NOW() WHERE created_at is NULL;
UPDATE users SET updated_at = NOW() WHERE updated_at is NULL;


-- 2. Таблица users была неудачно спроектирована. 
--    Записи created_at и updated_at были заданы типом VARCHAR 
--    и в них долгое время помещались значения в формате 20.10.2017 8:10. 
--    Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.

ALTER TABLE users CHANGE COLUMN created_at created_at_old VARCHAR(64);
ALTER TABLE users CHANGE COLUMN updated_at updated_at_old VARCHAR(64);
ALTER TABLE users ADD COLUMN created_at DATETIME;
ALTER TABLE users ADD COLUMN updated_at DATETIME;
UPDATE users SET created_at = created_at_old;
UPDATE users SET updated_at = updated_at_old;
ALTER TABLE users DROP COLUMN created_at_old;
ALTER TABLE users DROP COLUMN updated_at_old;

-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться 
--    самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. 
--    Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. 
--    Однако нулевые запасы должны выводиться в конце, после всех записей.

SELECT 
	id, storehouse_id, product_id, value, created_at, updated_at 
FROM 
	storehouses_products sp 
ORDER BY 
	IF(value = 0, 4294967295, value);

-- 4. Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. 
--    Месяцы заданы в виде списка английских названий (may, august)

SELECT 
	name, 
	DATE_FORMAT(birthday_at, "%M") AS birthday_month 
FROM 
	users 
WHERE 
	MONTH(birthday_at) = 5 OR MONTH(birthday_at) = 8 ;



-- 5. Из таблицы catalogs извлекаются записи при помощи запроса. 
--    SELECT * FROM catalogs WHERE id IN (5, 1, 2); 
--    Отсортируйте записи в порядке, заданном в списке IN.

SELECT * FROM catalogs WHERE id IN (5, 1, 2) 
ORDER BY 
	CASE 
		WHEN id = 5 THEN 0
		WHEN id = 1 THEN 1
		WHEN id = 2 THEN 2
		ELSE 1000
	END ; 



-- Практическое задание теме «Агрегация данных»

-- 1. Подсчитайте средний возраст пользователей в таблице users.

SELECT FLOOR(AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW()))) FROM users;


-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. 
--    Следует учесть, что необходимы дни недели текущего года, а не года рождения.

SELECT
	WEEKDAY(CONCAT(YEAR(NOW()), SUBSTRING(birthday_at,5,9))) AS day_of_birthday, 
	COUNT(*) AS total
FROM 
	users
GROUP BY
	day_of_birthday
ORDER BY
	day_of_birthday;


-- 3. Подсчитайте произведение чисел в столбце таблицы.

CREATE TABLE IF NOT EXISTS nums (value INT);
INSERT INTO nums VALUES (1), (2), (3), (4), (5);
SELECT EXP(SUM(LN(value))) FROM nums;

