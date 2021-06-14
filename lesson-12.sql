
-- Это простатая база данных для учета товаров по партиям
-- Партия это документ поступления товара (приходная накладная)
-- Учет товаров происходит через таблицу регистра накопления
-- У документов поступления и списания есть признак проведения.
-- Если документ списания проводится то он через триггер делает записи
-- в таблице регистра накопления при этом должна вычисляться себестоимость 
-- товара с учетом политики списания FIFO/LIFO.

DROP DATABASE IF EXISTS simple_erp;
CREATE DATABASE IF NOT EXISTS simple_erp;
USE simple_erp;
-- SHOW DATABASES;


DROP TABLE IF EXISTS organization;
CREATE TABLE IF NOT EXISTS organization (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL COMMENT "Наименование",
  address TEXT NULL COMMENT "Юр адрес",
  email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
  description TEXT NULL COMMENT "Описание",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT "Организации по которым ведется учет";  

INSERT INTO organization (name, address, email) VALUES 
	("MyOrganization", "Moscow, Tverskaya street 7", "info@myorg.com"),
	("SecondOrganization", "Moscow, Tverskaya street 20", "info@2org.com");
-- SELECT * FROM organization;


DROP TABLE IF EXISTS policy_type;
CREATE TABLE IF NOT EXISTS policy_type (
  id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL UNIQUE COMMENT "Наименование",
  description TEXT NULL COMMENT "Описание",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT "Виды учетных политик";  

INSERT INTO policy_type (name) VALUES 
	("FIFO"), ("LIFO");
-- SELECT * FROM policy_type;


DROP TABLE IF EXISTS accounting_policy;
CREATE TABLE IF NOT EXISTS accounting_policy (
  id SERIAL PRIMARY KEY,
  organization_id BIGINT UNSIGNED NOT NULL,
  policy_id BIGINT UNSIGNED NOT NULL,
  date_since DATE NOT NULL,
  FOREIGN KEY (organization_id) REFERENCES organization(id),
  FOREIGN KEY (policy_id) REFERENCES policy_type(id)
) COMMENT "Учетные политики огранизаций";  

INSERT INTO accounting_policy (organization_id, policy_id, date_since) VALUES 
	(1, 1, "2020-01-01"),
	(2, 2, "2020-01-01");
-- SELECT * FROM accounting_policy;


DROP TABLE IF EXISTS counterparty;
CREATE TABLE IF NOT EXISTS counterparty (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL COMMENT "Наименование",
  address TEXT NULL COMMENT "Юр адрес",
  email VARCHAR(100) NOT NULL UNIQUE COMMENT "Почта",
  description TEXT NULL COMMENT "Описание",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT "Контрагенты"; 
 INSERT INTO counterparty (name, address, email) VALUES 
	("Supplier LLC", "London, Rosebary Ave 7", "info@supplier.com"),
	("Bayer LLC", "New York, 5th Ave 20", "info@buyer.com");
-- SELECT * FROM counterparty;


DROP TABLE IF EXISTS position;
CREATE TABLE IF NOT EXISTS position (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(100) NOT NULL COMMENT "Название",
  description VARCHAR(100) NULL COMMENT "Описание",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT "Должности сотрудников"; 
 INSERT INTO position (name) VALUES 
	("Manager"),
	("Director");
-- SELECT * FROM position;


DROP TABLE IF EXISTS employee;
CREATE TABLE IF NOT EXISTS employee (
  id SERIAL PRIMARY KEY, 
  first_name VARCHAR(100) NOT NULL COMMENT "Имя",
  last_name VARCHAR(100) NOT NULL COMMENT "Фамилия",
  organization_id BIGINT UNSIGNED NOT NULL,
  position_id BIGINT UNSIGNED NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (organization_id) REFERENCES organization(id),
  FOREIGN KEY (position_id) REFERENCES `position`(id)
) COMMENT "Сотрудники"; 
 INSERT INTO employee (first_name, last_name, organization_id, position_id) VALUES 
	("Ivan", "Ivanov", 1, 1),
    ("Andrey", "Smirnov", 1, 2),
    ("Sergey", "Sidorov", 2, 1),
    ("John", "Smith", 2, 2);
-- SELECT * FROM employee;


DROP TABLE IF EXISTS document_type;
CREATE TABLE IF NOT EXISTS document_type (
  id SERIAL PRIMARY KEY,
  name VARCHAR(32) NOT NULL UNIQUE COMMENT "Наименование",
  description TEXT NULL COMMENT "Описание",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) COMMENT "Типы документов";  

INSERT INTO document_type (name, description) VALUES 
	("PurchaseInvoice", "Приходная накладная"), 
    ("SalesInvoice", "Расходная накладная");
-- SELECT * FROM document_type;


DROP TABLE IF EXISTS nomenclature;
CREATE TABLE IF NOT EXISTS nomenclature (
  id SERIAL PRIMARY KEY, 
  name VARCHAR(32) NOT NULL UNIQUE COMMENT "Наименование",
  description TEXT NULL COMMENT "Описание",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT "Номенклатура"; 
 INSERT INTO nomenclature (name) VALUES 
	("Pen Parker"),
    ("Pen Senator");
-- SELECT * FROM nomenclature;


DROP TABLE IF EXISTS invoiсe;
CREATE TABLE IF NOT EXISTS invoiсe (
  id SERIAL PRIMARY KEY,
  organization_id BIGINT UNSIGNED NOT NULL,
  counterparty_id BIGINT UNSIGNED NOT NULL,
  num VARCHAR(64) NOT NULL COMMENT "Номер документа",
  doc_date  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Дата документа",
  document_type_id BIGINT UNSIGNED NOT NULL,
  document_id BIGINT UNSIGNED NOT NULL,
  employee_id BIGINT UNSIGNED NOT NULL COMMENT "Ответственный",
  posted BOOLEAN NOT NULL DEFAULT 0 COMMENT "Признак поведенности доеумента",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (organization_id) REFERENCES organization(id),
  FOREIGN KEY (counterparty_id) REFERENCES counterparty(id),
  FOREIGN KEY (document_type_id) REFERENCES document_type(id),
  FOREIGN KEY (employee_id) REFERENCES employee(id)
) COMMENT "Документы накладные";
ALTER TABLE invoiсe ADD INDEX invoice_idx (document_type_id, id);
-- SELECT * FROM invoiсe;


DROP TABLE IF EXISTS invoiсe_tabular_section;
CREATE TABLE IF NOT EXISTS invoiсe_tabular_section (
  id SERIAL PRIMARY KEY,
  document_type_id BIGINT UNSIGNED NOT NULL,
  invoiсe_id BIGINT UNSIGNED NOT NULL,
  line INT NOT NULL COMMENT "Номер строки табличной части документа",
  nomenclature_id  BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на товар",
  amount INT UNSIGNED NOT NULL DEFAULT 1 COMMENT "Количество товара",
  cost DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT "Цена товара",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (document_type_id) REFERENCES document_type(id)
) COMMENT "Табличная часть накладных"; 
ALTER TABLE invoiсe_tabular_section ADD INDEX invoice_ts_idx (document_type_id, invoiсe_id);
-- SELECT * FROM invoiсe_tabular_section;


DROP TABLE IF EXISTS accumulation_register;
CREATE TABLE IF NOT EXISTS accumulation_register (
  id SERIAL PRIMARY KEY,
  organization_id BIGINT UNSIGNED NOT NULL,
  document_type_id BIGINT UNSIGNED NOT NULL,
  invoiсe_id BIGINT UNSIGNED NOT NULL,
  `action` BOOLEAN NOT NULL DEFAULT 1 COMMENT "Списание - 0, Приход - 1",
  line INT NOT NULL COMMENT "Номер строки табличной части документа",
  nomenclature_id  BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на товар",
  amount INT UNSIGNED NOT NULL DEFAULT 1 COMMENT "Количество товара",
  cost DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT "Стоимость товара",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (organization_id) REFERENCES organization(id),
  FOREIGN KEY (document_type_id) REFERENCES document_type(id),
  FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id)
) COMMENT "Регистр учета остатков номенклатуры"; 
ALTER TABLE accumulation_register ADD INDEX invoice_acreg_idx (document_type_id, invoiсe_id);
-- SELECT * FROM accumulation_register;



