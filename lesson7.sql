-- 1. Составьте список пользователей users, которые осуществили 
--    хотя бы один заказ orders в интернет магазине.

SELECT name FROM users JOIN orders ON users.id = orders.user_id;


-- 2. Выведите список товаров products и разделов catalogs, 
--    который соответствует товару.

SELECT 
	p.name, 
	c.name 
FROM 
	products p 
LEFT JOIN 
	catalogs c ON p.catalog_id = c.id;


-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) 
--    и таблица городов cities (label, name). Поля from, to и label содержат 
--    английские названия городов, поле name — русское. Выведите список 
--    рейсов flights с русскими названиями городов.

DROP TABLE IF EXISTS flights;
CREATE TABLE IF NOT EXISTS flights (
	`id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	`from` VARCHAR(64),
	`to` VARCHAR(64)
);
INSERT INTO	flights (`id`, `from`, `to`) VALUES
	(1, 'moscow', 'omsk'),
	(2, 'novgorod', 'kazan'),
	(3, 'irkutsk', 'moscow'),
	(4, 'omsk', 'irkutsk'),
	(5, 'moscow', 'kazan');
SELECT * FROM flights;

DROP TABLE IF EXISTS cities;
CREATE TABLE IF NOT EXISTS cities (
	label VARCHAR(64) PRIMARY KEY,
	name VARCHAR(64)
);
INSERT INTO	cities (`label`, `name`) VALUES
	('moscow', 'Москва'),
	('irkutsk', 'Иркутск'),
	('novgorod', 'Новгород'),
	('kazan', 'Казань'),
	('omsk', 'Омск');

SELECT * FROM cities;
	
SELECT 
	c1.name AS 'from', 
	c2.name AS 'to'
FROM 
	flights 
LEFT JOIN 
	cities AS c1 ON flights.`from` = c1.label
LEFT JOIN 
	cities AS c2 ON flights.`to` = c2.label ;		

