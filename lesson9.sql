-- “Транзакции, переменные, представления”
-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. 
--    Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users (name, birthday_at, created_at, updated_at)
SELECT name, birthday_at, created_at, updated_at FROM shop.users WHERE id = 1;
-- SELECT name, birthday_at, created_at, updated_at FROM sample.users;
-- SELECT name, birthday_at, created_at, updated_at FROM shop.users;
DELETE FROM shop.users WHERE id = 1;
COMMIT;


-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products 
--    и соответствующее название каталога name из таблицы catalogs.

DROP VIEW IF EXISTS products_with_catalogs;
CREATE VIEW products_with_catalogs AS 
	SELECT products.name AS product, catalogs.name AS `catalog` FROM products LEFT JOIN catalogs ON products.catalog_id = catalogs.id;
SELECT * FROM products_with_catalogs;

-- 3. (по желанию) Пусть имеется таблица с календарным полем created_at. 
--    В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', 
--    '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, 
--     выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.


-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. 
--    Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.




-- “Хранимые процедуры и функции, триггеры"
-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
--    С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать 
--    фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DROP FUNCTION IF EXISTS hello;

CREATE FUNCTION hello()
RETURNS TEXT NOT DETERMINISTIC
BEGIN
	DECLARE currant_hour INT;
	DECLARE greeting TEXT;
	SET currant_hour = HOUR(NOW());
	IF currant_hour >= 6 AND currant_hour < 12 THEN SET greeting = "Доброе утро";
	ELSEIF currant_hour >= 12 AND currant_hour < 18 THEN SET greeting = "Доброе день";
	ELSEIF currant_hour >= 18 THEN SET greeting = "Доброе вечер";
	ELSE SET greeting = "Доброе ночи";
	END IF;

	RETURN greeting;
END;

SELECT hello();


-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
--    Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное 
--    значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
--    При попытке присвоить полям NULL-значение необходимо отменить операцию.

DROP TRIGGER IF EXISTS products_name_desc_both_not_null;

CREATE TRIGGER products_name_desc_both_not_null BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
	IF COALESCE(NEW.name, NEW.description) <=> NULL THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE canceled (name and desc both null)';
	END IF;
END;

-- SELECT * from products;
-- INSERT INTO products (name, description, price, catalog_id) VALUE ("test name", "test desc", 123, 1);
-- UPDATE products SET name = NULL, description = NULL WHERE id = 8;


-- 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
--    Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
--    Вызов функции FIBONACCI(10) должен возвращать число 55.

DROP FUNCTION IF EXISTS FIBONACCI;

CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT DETERMINISTIC
BEGIN
	DECLARE fib_sum INT DEFAULT 0;
	DECLARE fib1 INT DEFAULT 0;
	DECLARE fib2 INT DEFAULT 1;
	DECLARE i INT DEFAULT 0;

	IF num = 0 THEN RETURN 0;
	ELSE
		SET num = num - 1;
		WHILE i < num DO
			SET fib_sum = fib1 + fib2;
			SET fib1 = fib2;
			SET fib2 = fib_sum;
			SET i = i + 1;
		END WHILE;
	END IF;
	RETURN fib2;
END;

SELECT FIBONACCI(10);
