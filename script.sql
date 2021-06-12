CREATE DATABASE IF NOT EXISTS example;
use example

CREATE TABLE IF NOT EXISTS users (id SERIAL PRIMARY KEY, name VARCHAR(64));

INSERT INTO users (name) VALUES 
	('John'),
	('Alex'),
	('Eric'),
	('Alfred'),
    ('Leonard');

SELECT * FROM users;

-- Make dump:
-- mysqldump -h 127.0.0.1 -P3306 -u root -p example > dump.sql

CREATE DATABASE IF NOT EXISTS sample;

-- Load dump to sample database:
-- mysql -h 127.0.0.1 -P3306 -u root -p sample < dump.sql
