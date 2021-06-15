
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


DROP TABLE IF EXISTS invoice;
CREATE TABLE IF NOT EXISTS invoice (
  id SERIAL PRIMARY KEY,
  organization_id BIGINT UNSIGNED NOT NULL,
  counterparty_id BIGINT UNSIGNED NOT NULL,
  num VARCHAR(64) NOT NULL COMMENT "Номер документа",
  doc_date  DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Дата документа",
  document_type_id BIGINT UNSIGNED NOT NULL,
  employee_id BIGINT UNSIGNED NOT NULL COMMENT "Ответственный",
  posted BOOLEAN NOT NULL DEFAULT 0 COMMENT "Признак поведенности доеумента",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (organization_id) REFERENCES organization(id),
  FOREIGN KEY (counterparty_id) REFERENCES counterparty(id),
  FOREIGN KEY (document_type_id) REFERENCES document_type(id),
  FOREIGN KEY (employee_id) REFERENCES employee(id)
) COMMENT "Документы накладные";
ALTER TABLE invoice ADD INDEX invoice_idx (document_type_id, id);
-- SELECT * FROM invoiсe;


DROP TABLE IF EXISTS invoice_tabular_section;
CREATE TABLE IF NOT EXISTS invoice_tabular_section (
  id SERIAL PRIMARY KEY,
  invoice_id BIGINT UNSIGNED NOT NULL,
  line INT NOT NULL COMMENT "Номер строки табличной части документа",
  nomenclature_id  BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на товар",
  amount INT UNSIGNED NOT NULL DEFAULT 1 COMMENT "Количество товара",
  cost DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT "Цена товара",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (invoice_id) REFERENCES invoice(id)
) COMMENT "Табличная часть накладных"; 
-- SELECT * FROM invoiсe_tabular_section;


DROP TABLE IF EXISTS accumulation_register;
CREATE TABLE IF NOT EXISTS accumulation_register (
  id SERIAL PRIMARY KEY,
  period DATETIME DEFAULT CURRENT_TIMESTAMP,
  organization_id BIGINT UNSIGNED NOT NULL,
  invoice_id BIGINT UNSIGNED NOT NULL,
  `action` BOOLEAN NOT NULL DEFAULT 1 COMMENT "Списание - 0, Приход - 1",
  line INT NOT NULL COMMENT "Номер строки табличной части документа",
  nomenclature_id  BIGINT UNSIGNED NOT NULL COMMENT "Ссылка на товар",
  amount INT UNSIGNED NOT NULL DEFAULT 1 COMMENT "Количество товара",
  total DECIMAL(10, 2) NOT NULL DEFAULT 0 COMMENT "Стоимость товара",
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,  
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (organization_id) REFERENCES organization(id),
  FOREIGN KEY (invoice_id) REFERENCES invoice(id),
  FOREIGN KEY (nomenclature_id) REFERENCES nomenclature(id)
) COMMENT "Регистр учета остатков номенклатуры"; 
-- SELECT * FROM accumulation_register;


-- Процедура распроведения накладной (удаляются все данные по накладной в учетном регистре)
DROP PROCEDURE IF EXISTS unpost_invoice;
DELIMITER //
CREATE PROCEDURE unpost_invoice(inv_id BIGINT) BEGIN
	-- удаляем все записи в регистре по накладной
    DELETE FROM accumulation_register WHERE invoice_id = inv_id;
    UPDATE invoice SET posted = 0 WHERE id = inv_id;
END//
DELIMITER ;


-- Процедура проведения приходной накладной (формируются записи по накладной в учетном регистре)
DROP PROCEDURE IF EXISTS post_purchase_invoice;
DELIMITER //
CREATE PROCEDURE post_purchase_invoice(purchase_invoice_id BIGINT) BEGIN
    DECLARE done bool default 0;
    DECLARE org_id BIGINT;
    DECLARE doc_date DATETIME;
    DECLARE line INT;
    DECLARE nom_id BIGINT;
    DECLARE amount INT;
    DECLARE cost DECIMAL(10, 2);
    DECLARE cur cursor for SELECT inv.organization_id, inv.doc_date, tab.line, tab.nomenclature_id, tab.amount, tab.cost FROM invoice_tabular_section AS tab LEFT JOIN invoice AS inv ON tab.invoice_id=inv.id WHERE tab.invoice_id=purchase_invoice_id;
    DECLARE continue handler for not found set done = true;
    -- DELETE FROM accumulation_register WHERE invoice_id = purchase_invoice_id;
    CALL unpost_invoice(purchase_invoice_id);
    OPEN cur;

    read_loop: loop
        fetch cur into org_id, doc_date, line, nom_id, amount, cost;
        if done then
            leave read_loop;
        END IF;
        INSERT INTO accumulation_register (`period`, `organization_id`, `invoice_id`, `action`, `line`, `nomenclature_id`, `amount`, `total`) VALUES (doc_date, org_id, purchase_invoice_id, 1, line, nom_id, amount, cost);
	END loop;
    UPDATE invoice SET posted = 1 WHERE id = purchase_invoice_id;
END//
DELIMITER ;



-- Приходная накладная 00001 от 2020-11-15 12:00
INSERT INTO invoice (organization_id, counterparty_id, num, doc_date, document_type_id, employee_id) VALUES 
	(1, 1, "00001", "2020-11-15 12:00", 1, 1);
-- Табличная часть к Приходной накладной 00001 от 2020-11-15 12:00   
INSERT INTO invoice_tabular_section (invoice_id, line, nomenclature_id, amount, cost) VALUES 
	(1, 1, 1, 5, 500), -- Pen Parker  $100 за штуку
    (1, 2, 2, 3, 450); -- Pen Senator $150 за штуку
 
SELECT inv.num, inv.doc_date, typ.name AS doc_type, org.name AS org, c.name AS partner, emp.first_name, emp.last_name, CASE WHEN inv.posted THEN "YES" ELSE "NO" END AS "POSTED", tab.line, n.name AS product, tab.amount, tab.cost
FROM invoice AS inv 
LEFT JOIN invoice_tabular_section AS tab ON inv.id = tab.invoice_id
LEFT JOIN document_type AS typ ON inv.document_type_id = typ.id
LEFT JOIN employee AS emp ON inv.employee_id = emp.id
LEFT JOIN organization AS org ON inv.organization_id = org.id
LEFT JOIN counterparty AS c ON inv.counterparty_id = c.id 
LEFT JOIN nomenclature AS n ON tab.nomenclature_id = n.id
WHERE inv.num = "00001" AND inv.document_type_id = 1
ORDER BY line;
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- | num   | doc_date            | doc_type        | org            | partner      | first_name | last_name | POSTED | line | product     | amount | cost   |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- | 00001 | 2020-11-15 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Ivan       | Ivanov    | NO     |    1 | Pen Parker  |      5 | 500.00 |
-- | 00001 | 2020-11-15 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Ivan       | Ivanov    | NO     |    2 | Pen Senator |      3 | 450.00 |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- 2 rows in set (0.00 sec)

-- Проводим приходную накладную 00001
CALL post_purchase_invoice(1);
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- | num   | doc_date            | doc_type        | org            | partner      | first_name | last_name | POSTED | line | product     | amount | cost   |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- | 00001 | 2020-11-15 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Ivan       | Ivanov    | YES    |    1 | Pen Parker  |      5 | 500.00 |
-- | 00001 | 2020-11-15 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Ivan       | Ivanov    | YES    |    2 | Pen Senator |      3 | 450.00 |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- 2 rows in set (0.00 sec)

-- Смотрим движения в учетном регистре
SELECT acreg.period, org.name AS Org, inv.num, typ.name AS doc_type, acreg.`action`, acreg.line, n.name AS product, acreg.amount, acreg.total  FROM accumulation_register AS acreg
LEFT JOIN organization AS org ON acreg.organization_id = org.id
LEFT JOIN nomenclature AS n ON acreg.nomenclature_id = n.id
LEFT JOIN invoice AS inv ON acreg.invoice_id = inv.id
LEFT JOIN document_type AS typ ON inv.document_type_id = typ.id;
-- +---------------------+----------------+-------+-----------------+--------+------+-------------+--------+--------+
-- | period              | Org            | num   | doc_type        | action | line | product     | amount | total  |
-- +---------------------+----------------+-------+-----------------+--------+------+-------------+--------+--------+
-- | 2020-11-15 12:00:00 | MyOrganization | 00001 | PurchaseInvoice |      1 |    1 | Pen Parker  |      5 | 500.00 |
-- | 2020-11-15 12:00:00 | MyOrganization | 00001 | PurchaseInvoice |      1 |    2 | Pen Senator |      3 | 450.00 |
-- +---------------------+----------------+-------+-----------------+--------+------+-------------+--------+--------+
-- 2 rows in set (0.01 sec)

-- Приходная накладная 00002 от 2020-11-20 12:00   
INSERT INTO invoice (organization_id, counterparty_id, num, doc_date, document_type_id, employee_id) VALUES 
	(1, 1, "00002", "2020-11-20 12:00", 1, 1);
-- Табличная часть к Приходной накладной 00002 от 2020-11-20 12:00   
INSERT INTO invoice_tabular_section (invoice_id, line, nomenclature_id, amount, cost) VALUES 
	(2, 1, 1, 2, 400), -- Pen Parker  $200 за штуку
    (2, 2, 2, 1, 200); -- Pen Senator $200 за штуку
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- | num   | doc_date            | doc_type        | org            | partner      | first_name | last_name | POSTED | line | product     | amount | cost   |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- | 00002 | 2020-11-20 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Ivan       | Ivanov    | NO     |    1 | Pen Parker  |      2 | 400.00 |
-- | 00002 | 2020-11-20 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Ivan       | Ivanov    | NO     |    2 | Pen Senator |      1 | 200.00 |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+--------+
-- 2 rows in set (0.00 sec)  

-- Проводим приходную накладную 00002
CALL post_purchase_invoice(2);
  
   
-- Приходная накладная 00003 от 2020-11-30 12:00   
INSERT INTO invoice (organization_id, counterparty_id, num, doc_date, document_type_id, employee_id) VALUES 
	(1, 1, "00003", "2020-11-30 12:00", 1, 2);
-- Табличная часть к Приходной накладной 00003 от 2020-11-30 12:00   
INSERT INTO invoice_tabular_section (invoice_id, line, nomenclature_id, amount, cost) VALUES 
	(3, 1, 1, 10, 500), -- Pen Parker  $50 за штуку
    (3, 2, 2, 4, 1000); -- Pen Senator $200 за штуку   
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+---------+
-- | num   | doc_date            | doc_type        | org            | partner      | first_name | last_name | POSTED | line | product     | amount | cost    |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+---------+
-- | 00003 | 2020-11-30 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Andrey     | Smirnov   | NO     |    1 | Pen Parker  |     10 |  500.00 |
-- | 00003 | 2020-11-30 12:00:00 | PurchaseInvoice | MyOrganization | Supplier LLC | Andrey     | Smirnov   | NO     |    2 | Pen Senator |      4 | 1000.00 |
-- +-------+---------------------+-----------------+----------------+--------------+------------+-----------+--------+------+-------------+--------+---------+
-- 2 rows in set (0.00 sec)   

-- Проводим приходную накладную 00003
CALL post_purchase_invoice(3);


-- Расходная накладная 00001 от 2020-12-01 12:00   
INSERT INTO invoice (organization_id, counterparty_id, num, doc_date, document_type_id, employee_id) VALUES 
	(1, 2, "00001", "2020-11-30 12:00", 2, 2);
-- Табличная часть к Расходной накладной 00001 от 2020-11-15 12:00   
INSERT INTO invoice_tabular_section (invoice_id, line, nomenclature_id, amount, cost) VALUES 
	(4, 1, 1, 6, 1500), -- Pen Parker  FIFO costs $700, LIFO costs $300
    (4, 2, 2, 5, 2500); -- Pen Senator FIFO costs $900, LIFO costs $1200   
-- +-------+---------------------+--------------+----------------+-----------+------------+-----------+--------+------+-------------+--------+---------+
-- | num   | doc_date            | doc_type     | org            | partner   | first_name | last_name | POSTED | line | product     | amount | cost    |
-- +-------+---------------------+--------------+----------------+-----------+------------+-----------+--------+------+-------------+--------+---------+
-- | 00001 | 2020-11-30 12:00:00 | SalesInvoice | MyOrganization | Bayer LLC | Andrey     | Smirnov   | NO     |    1 | Pen Parker  |      6 | 1500.00 |
-- | 00001 | 2020-11-30 12:00:00 | SalesInvoice | MyOrganization | Bayer LLC | Andrey     | Smirnov   | NO     |    2 | Pen Senator |      5 | 2500.00 |
-- +-------+---------------------+--------------+----------------+-----------+------------+-----------+--------+------+-------------+--------+---------+
-- 2 rows in set (0.01 sec)
   
-- Процедура проведения для расходных накладных не реализована, не хватило времени :(


