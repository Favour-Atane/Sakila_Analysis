-- Sakila Sample Database Schema
-- Version 1.5

-- Copyright (c) 2006, 2024, Oracle and/or its affiliates.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:

-- * Redistributions of source code must retain the above copyright notice,
--   this list of conditions and the following disclaimer.
-- * Redistributions in binary form must reproduce the above copyright
--   notice, this list of conditions and the following disclaimer in the
--   documentation and/or other materials provided with the distribution.
-- * Neither the name of Oracle nor the names of its contributors may be used
--   to endorse or promote products derived from this software without
--   specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
-- IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
-- CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
-- EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
-- PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
-- LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

SET NAMES utf8mb4;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS sakila;
CREATE SCHEMA sakila;
create Database sakila;
USE sakila;

--
-- Table structure for table `actor`
--

CREATE TABLE actor (
    actor_id SMALLINT NOT NULL IDENTITY(1,1),
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    last_update DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (actor_id),
    INDEX idx_actor_last_name (last_name) -- Use INDEX for creating a non-clustered index
);
-- Create city table first
CREATE TABLE city (
    city_id SMALLINT NOT NULL IDENTITY(1,1),
    city_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (city_id)
);
--
-- Table structure for table `address`
--

CREATE TABLE address (
    address_id SMALLINT NOT NULL IDENTITY(1,1),
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50) NULL,
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT NOT NULL,
    postal_code VARCHAR(10) NULL,
    phone VARCHAR(20) NOT NULL,
    -- Commenting out the GEOMETRY column for now
    -- location GEOGRAPHY NULL, -- or use GEOMETRY if appropriate
    last_update DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (address_id),
    FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE no action ON UPDATE CASCADE
);

-- Create index on city_id
CREATE INDEX idx_fk_city_id ON address(city_id);

-- Uncomment and adjust if using GEOMETRY
-- CREATE SPATIAL INDEX idx_location ON address(location);

--
-- Table structure for table `category`
--

CREATE TABLE category (
    category_id TINYINT NOT NULL IDENTITY(1,1),
    name VARCHAR(25) NOT NULL,
    last_update DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (category_id)
);

--
-- Table structure for table `city`
--

-- Add or modify columns
ALTER TABLE city
    -- Add the `last_update` column if it does not exist
    ADD last_update DATETIME NOT NULL DEFAULT GETDATE();
ALTER TABLE city
ADD country_id SMALLINT NOT NULL;

-- Create or update indexes
-- Create the index if it does not exist
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_fk_country_id' AND object_id = OBJECT_ID('city'))
BEGIN
    CREATE INDEX idx_fk_country_id ON city(country_id);
END

-- Add or update foreign key constraint
-- Drop the existing foreign key constraint if it exists
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_city_country')
BEGIN
    ALTER TABLE city DROP CONSTRAINT fk_city_country;
END

-- Add the foreign key constraint
ALTER TABLE city
    ADD CONSTRAINT fk_city_country
    FOREIGN KEY (country_id) REFERENCES country (country_id)
    ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Table structure for table `country`
--

CREATE TABLE country (
    country_id SMALLINT NOT NULL IDENTITY(1,1),
    country VARCHAR(50) NOT NULL,
    last_update DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (country_id)
);
--
-- Table structure for table `customer`
--
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'store')
BEGIN
    CREATE TABLE store (
        store_id TINYINT NOT NULL IDENTITY(1,1),
        store_name VARCHAR(50) NOT NULL,
        PRIMARY KEY (store_id)
    );
END

-- Create the customer table

CREATE TABLE customer (
    customer_id SMALLINT NOT NULL IDENTITY(1,1),
    store_id TINYINT NOT NULL,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    email VARCHAR(50) NULL,
    address_id SMALLINT NOT NULL,
    active BIT NOT NULL DEFAULT 1, -- Use BIT for BOOLEAN in SQL Server
    create_date DATETIME NOT NULL,
    last_update DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (customer_id)
);
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_customer_address')
BEGIN
    ALTER TABLE customer DROP CONSTRAINT fk_customer_address;
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_customer_store')
BEGIN
    ALTER TABLE customer DROP CONSTRAINT fk_customer_store;
END
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'store')
BEGIN
    CREATE TABLE store (
        store_id TINYINT NOT NULL IDENTITY(1,1),
        store_name VARCHAR(50) NOT NULL,
        PRIMARY KEY (store_id)
    );
END
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'address')
BEGIN
    CREATE TABLE address (
        address_id SMALLINT NOT NULL IDENTITY(1,1),
        address VARCHAR(50) NOT NULL,
        address2 VARCHAR(50) NULL,
        district VARCHAR(20) NOT NULL,
        city_id SMALLINT NOT NULL,
        postal_code VARCHAR(10) NULL,
        phone VARCHAR(20) NOT NULL,
        last_update DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (address_id)
    );
END
-- Create the customer table
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'customer')
BEGIN
    CREATE TABLE customer (
        customer_id SMALLINT NOT NULL IDENTITY(1,1),
        store_id TINYINT NOT NULL,
        first_name VARCHAR(45) NOT NULL,
        last_name VARCHAR(45) NOT NULL,
        email VARCHAR(50) NULL,
        address_id SMALLINT NOT NULL,
        active BIT NOT NULL DEFAULT 1, -- Use BIT for BOOLEAN in SQL Server
        create_date DATETIME NOT NULL,
        last_update DATETIME DEFAULT GETDATE(),
        PRIMARY KEY (customer_id)
    );
END

-- Create indexes
-- Index on store_id
CREATE INDEX idx_fk_store_id ON customer(store_id);

-- Index on address_id
CREATE INDEX idx_fk_address_id ON customer(address_id);

-- Index on last_name
CREATE INDEX idx_last_name ON customer(last_name);

-- Add foreign key constraints
ALTER TABLE customer
    ADD CONSTRAINT fk_customer_address
    FOREIGN KEY (address_id) REFERENCES address (address_id)
    ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE customer
    ADD CONSTRAINT fk_customer_store
    FOREIGN KEY (store_id) REFERENCES store (store_id)
    ON DELETE NO ACTION ON UPDATE CASCADE;
-- Create indexes
-- Index on store_id
CREATE INDEX idx_fk_store_id ON customer(store_id);

-- Index on address_id
CREATE INDEX idx_fk_address_id ON customer(address_id);

-- Index on last_name
CREATE INDEX idx_last_name ON customer(last_name);

-- Add foreign key constraints
-- Drop the existing foreign key constraints if they exist
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_customer_address')
BEGIN
    ALTER TABLE customer DROP CONSTRAINT fk_customer_address;
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'fk_customer_store')
BEGIN
    ALTER TABLE customer DROP CONSTRAINT fk_customer_store;
END

-- Add foreign key constraints
ALTER TABLE customer
    ADD CONSTRAINT fk_customer_address
    FOREIGN KEY (address_id) REFERENCES address (address_id)
    ON DELETE NO ACTION ON UPDATE CASCADE;

ALTER TABLE customer
    ADD CONSTRAINT fk_customer_store
    FOREIGN KEY (store_id) REFERENCES store (store_id)
    ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Table structure for table `film`
--
CREATE TABLE language (
  language_id TINYINT NOT NULL PRIMARY KEY,  -- Unique identifier for each language
  name VARCHAR(50) NOT NULL  -- Name of the language
);

CREATE TABLE film (
  film_id SMALLINT IDENTITY(1,1) NOT NULL PRIMARY KEY,  -- Unique identifier for each film, auto-incremented
  title VARCHAR(128) NOT NULL,  -- Title of the film
  description TEXT NULL,  -- Description of the film
  release_year INT NULL,  -- Release year of the film
  language_id TINYINT NOT NULL,  -- ID of the language in which the film is available
  original_language_id TINYINT NULL,  -- ID of the original language of the film (if different)
  rental_duration TINYINT NOT NULL DEFAULT 3,  -- Duration of rental period in days
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,  -- Rate for renting the film
  length SMALLINT NULL,  -- Length of the film in minutes
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,  -- Replacement cost of the film
  rating VARCHAR(5) CHECK (rating IN ('G', 'PG', 'PG-13', 'R', 'NC-17')) DEFAULT 'G',  -- Rating of the film
  special_features VARCHAR(255) NULL,  -- Special features available with the film
  last_update DATETIME NOT NULL DEFAULT GETDATE(),  -- Timestamp of the last update
  CONSTRAINT FK_film_language FOREIGN KEY (language_id) REFERENCES language(language_id) ON DELETE NO ACTION ON UPDATE NO ACTION,  -- Foreign key constraint linking to the language table
  CONSTRAINT FK_film_language_original FOREIGN KEY (original_language_id) REFERENCES language(language_id) ON DELETE NO ACTION ON UPDATE NO ACTION  -- Foreign key constraint linking to the language table for original language
);

--
-- Table structure for table `film_actor`
--
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'actor';

CREATE TABLE film_actor (
  actor_id SMALLINT NOT NULL,  -- ID of the actor
  film_id SMALLINT NOT NULL,  -- ID of the film
  last_update DATETIME NOT NULL DEFAULT GETDATE(),  -- Timestamp of the last update
  PRIMARY KEY (actor_id, film_id),  -- Composite primary key
  CONSTRAINT FK_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE NO ACTION ON UPDATE NO ACTION,  -- Foreign key constraint linking to the actor table
  CONSTRAINT FK_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE NO ACTION ON UPDATE NO ACTION  -- Foreign key constraint linking to the film table
);

--
-- Table structure for table `film_category`
--
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'category';
CREATE TABLE category (
  category_id TINYINT NOT NULL PRIMARY KEY,  -- Unique identifier for each category
  name VARCHAR(100) NOT NULL  -- Name of the category
);
CREATE TABLE film_category (
  film_id SMALLINT NOT NULL,  -- ID of the film
  category_id TINYINT NOT NULL,  -- ID of the category
  last_update DATETIME NOT NULL DEFAULT GETDATE(),  -- Timestamp of the last update
  PRIMARY KEY (film_id, category_id),  -- Composite primary key
  CONSTRAINT FK_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE NO ACTION ON UPDATE NO ACTION,  -- Foreign key constraint linking to the film table
  CONSTRAINT FK_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE NO ACTION ON UPDATE NO ACTION  -- Foreign key constraint linking to the category table
);

--
-- Table structure for table `film_text`
-- 
-- InnoDB added FULLTEXT support in 5.6.10. If you use an
-- earlier version, then consider upgrading (recommended) or 
-- changing InnoDB to MyISAM as the film_text engine
--

-- Use InnoDB for film_text as of 5.6.10, MyISAM prior to 5.6.10.
SET @old_default_storage_engine = @@default_storage_engine;
SET @@default_storage_engine = 'MyISAM';
/*!50610 SET @@default_storage_engine = 'InnoDB'*/;

CREATE TABLE film_text (
  film_id SMALLINT NOT NULL,  -- ID of the film
  title NVARCHAR(255) NOT NULL,  -- Title of the film
  description NVARCHAR(MAX),  -- Description of the film
  PRIMARY KEY (film_id)  -- Primary key for the film_id
);

SET @@default_storage_engine = @old_default_storage_engine;
ALTER DATABASE YourDatabaseName SET COMPATIBILITY_LEVEL = 110;  -- Example for SQL Server 2012
--
-- Triggers for loading film_text from film
--
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'film';

-- Verify the data types in the film_text table
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'film_text';
DELIMITER ;;
CREATE TABLE film (
    film_id SMALLINT NOT NULL PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX)
);

-- Create film_text table
CREATE TABLE film_text (
    film_id SMALLINT NOT NULL,
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    PRIMARY KEY (film_id)
);

-- Create the trigger
ALTER TABLE film
ALTER COLUMN description NVARCHAR(MAX);

-- Modify the film_text table if necessary
ALTER TABLE film_text
ALTER COLUMN description NVARCHAR(MAX);
IF OBJECT_ID('ins_film', 'TR') IS NOT NULL
    DROP TRIGGER ins_film;

-- Recreate the trigger
CREATE TRIGGER ins_film
ON film
AFTER INSERT
AS
BEGIN
    INSERT INTO film_text (film_id, title, description)
    SELECT i.film_id, i.title, i.description
    FROM inserted i;
END;

CREATE TRIGGER upd_film
ON film
AFTER UPDATE
AS
BEGIN
    -- Update film_text if there are changes in title, description, or film_id
    UPDATE film_text
    SET title = i.title,
        description = i.description,
        film_id = i.film_id
    FROM inserted i
    INNER JOIN deleted d ON i.film_id = d.film_id
    WHERE (i.title != d.title) 
       OR (i.description != d.description)
       OR (i.film_id != d.film_id);
END;


CREATE TRIGGER del_film
ON film
AFTER DELETE
AS
BEGIN
    -- Delete from film_text where the film_id matches the deleted film_id
    DELETE FROM film_text
    WHERE film_id IN (SELECT film_id FROM deleted);
END;


--
-- Table structure for table `inventory`
--

CREATE TABLE inventory (
    inventory_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    film_id SMALLINT NOT NULL,
    store_id TINYINT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    -- Indexes
    CONSTRAINT idx_fk_film_id UNIQUE NONCLUSTERED (film_id),
    CONSTRAINT idx_store_id_film_id UNIQUE NONCLUSTERED (store_id, film_id),
    -- Foreign Keys
    CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) 
        REFERENCES store (store_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE,
    CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) 
        REFERENCES film (film_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE
);

--
-- Table structure for table `language`
--

CREATE TABLE new_language (
    language_id TINYINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    name CHAR(20) NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

--
-- Table structure for table `payment`
--

CREATE TABLE payment (
    payment_id SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    customer_id SMALLINT NOT NULL,
    staff_id TINYINT NOT NULL,
    rental_id INT NULL,
    amount DECIMAL(5,2) NOT NULL,
    payment_date DATETIME2 NOT NULL,
    last_update DATETIME2 DEFAULT SYSDATETIME(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) 
        REFERENCES rental (rental_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE,
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) 
        REFERENCES customer (customer_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE,
    CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) 
        REFERENCES staff (staff_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE
);

-- Create indexes separately
CREATE NONCLUSTERED INDEX idx_fk_staff_id
ON payment (staff_id);

CREATE NONCLUSTERED INDEX idx_fk_customer_id
ON payment (customer_id);

--
-- Table structure for table `rental`
--

CREATE TABLE rental (
    rental_id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    rental_date DATETIME2 NOT NULL,
    inventory_id INT NOT NULL,
    customer_id SMALLINT NOT NULL,
    return_date DATETIME2 NULL,
    staff_id TINYINT NOT NULL,
    last_update DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) 
        REFERENCES staff (staff_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE,
    CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) 
        REFERENCES inventory (inventory_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE,
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) 
        REFERENCES customer (customer_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE
);

-- Create unique and non-clustered indexes separately
CREATE UNIQUE NONCLUSTERED INDEX idx_rental_date_inventory_customer
ON rental (rental_date, inventory_id, customer_id);

CREATE NONCLUSTERED INDEX idx_fk_inventory_id
ON rental (inventory_id);

CREATE NONCLUSTERED INDEX idx_fk_customer_id
ON rental (customer_id);

CREATE NONCLUSTERED INDEX idx_fk_staff_id
ON rental (staff_id);
drop table staff;
--
-- Table structure for table `staff`
--

CREATE TABLE staff (
    staff_id SMALLINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    address_id SMALLINT NOT NULL,
    picture VARBINARY(MAX) NULL,
    email VARCHAR(50) NULL,
    store_id TINYINT NOT NULL,
    active BIT NOT NULL DEFAULT 1,
    username VARCHAR(16) NOT NULL,
    password VARCHAR(40) COLLATE Latin1_General_BIN NULL,
    last_update DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    
    -- Foreign Key Constraints
    CONSTRAINT fk_staff_store FOREIGN KEY (store_id) 
        REFERENCES store (store_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE,
    CONSTRAINT fk_staff_address FOREIGN KEY (address_id) 
        REFERENCES address (address_id) 
        ON DELETE NO ACTION 
        ON UPDATE CASCADE
);

-- Create indexes separately
CREATE NONCLUSTERED INDEX idx_fk_store_id
ON staff (store_id);

CREATE NONCLUSTERED INDEX idx_fk_address_id
ON staff (address_id);
--
-- Table structure for table `store`
--

CREATE TABLE store (
  store_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  manager_staff_id TINYINT UNSIGNED NOT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (store_id),
  UNIQUE KEY idx_unique_manager (manager_staff_id),
  KEY idx_fk_address_id (address_id),
  CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- View structure for view `customer_list`
--

CREATE VIEW customer_list
AS
SELECT cu.customer_id AS ID, CONCAT(cu.first_name, _utf8mb4' ', cu.last_name) AS name, a.address AS address, a.postal_code AS `zip code`,
	a.phone AS phone, city.city AS city, country.country AS country, IF(cu.active, _utf8mb4'active',_utf8mb4'') AS notes, cu.store_id AS SID
FROM customer AS cu JOIN address AS a ON cu.address_id = a.address_id JOIN city ON a.city_id = city.city_id
	JOIN country ON city.country_id = country.country_id;

--
-- View structure for view `film_list`
--

CREATE VIEW film_list
AS
SELECT film.film_id AS FID, film.title AS title, film.description AS description, category.name AS category, film.rental_rate AS price,
	film.length AS length, film.rating AS rating, GROUP_CONCAT(CONCAT(actor.first_name, _utf8mb4' ', actor.last_name) SEPARATOR ', ') AS actors
FROM film LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id LEFT
JOIN film_actor ON film.film_id = film_actor.film_id LEFT JOIN actor ON
  film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;

--
-- View structure for view `nicer_but_slower_film_list`
--

CREATE VIEW nicer_but_slower_film_list
AS
SELECT film.film_id AS FID, film.title AS title, film.description AS description, category.name AS category, film.rental_rate AS price,
	film.length AS length, film.rating AS rating, GROUP_CONCAT(CONCAT(CONCAT(UCASE(SUBSTR(actor.first_name,1,1)),
	LCASE(SUBSTR(actor.first_name,2,LENGTH(actor.first_name))),_utf8mb4' ',CONCAT(UCASE(SUBSTR(actor.last_name,1,1)),
	LCASE(SUBSTR(actor.last_name,2,LENGTH(actor.last_name)))))) SEPARATOR ', ') AS actors
FROM film LEFT JOIN film_category ON film_category.film_id = film.film_id
LEFT JOIN category ON category.category_id = film_category.category_id LEFT
JOIN film_actor ON film.film_id = film_actor.film_id LEFT JOIN actor ON
  film_actor.actor_id = actor.actor_id
GROUP BY film.film_id, category.name;

--
-- View structure for view `staff_list`
--

CREATE VIEW staff_list
AS
SELECT s.staff_id AS ID, CONCAT(s.first_name, _utf8mb4' ', s.last_name) AS name, a.address AS address, a.postal_code AS `zip code`, a.phone AS phone,
	city.city AS city, country.country AS country, s.store_id AS SID
FROM staff AS s JOIN address AS a ON s.address_id = a.address_id JOIN city ON a.city_id = city.city_id
	JOIN country ON city.country_id = country.country_id;

--
-- View structure for view `sales_by_store`
--

CREATE VIEW sales_by_store
AS
SELECT
CONCAT(c.city, _utf8mb4',', cy.country) AS store
, CONCAT(m.first_name, _utf8mb4' ', m.last_name) AS manager
, SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN store AS s ON i.store_id = s.store_id
INNER JOIN address AS a ON s.address_id = a.address_id
INNER JOIN city AS c ON a.city_id = c.city_id
INNER JOIN country AS cy ON c.country_id = cy.country_id
INNER JOIN staff AS m ON s.manager_staff_id = m.staff_id
GROUP BY s.store_id
ORDER BY cy.country, c.city;

--
-- View structure for view `sales_by_film_category`
--
-- Note that total sales will add up to >100% because
-- some titles belong to more than 1 category
--

CREATE VIEW sales_by_film_category
AS
SELECT
c.name AS category
, SUM(p.amount) AS total_sales
FROM payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sales DESC;

--
-- View structure for view `actor_info`
--

CREATE DEFINER=CURRENT_USER SQL SECURITY INVOKER VIEW actor_info
AS
SELECT
a.actor_id,
a.first_name,
a.last_name,
GROUP_CONCAT(DISTINCT CONCAT(c.name, ': ',
		(SELECT GROUP_CONCAT(f.title ORDER BY f.title SEPARATOR ', ')
                    FROM sakila.film f
                    INNER JOIN sakila.film_category fc
                      ON f.film_id = fc.film_id
                    INNER JOIN sakila.film_actor fa
                      ON f.film_id = fa.film_id
                    WHERE fc.category_id = c.category_id
                    AND fa.actor_id = a.actor_id
                 )
             )
             ORDER BY c.name SEPARATOR '; ')
AS film_info
FROM sakila.actor a
LEFT JOIN sakila.film_actor fa
  ON a.actor_id = fa.actor_id
LEFT JOIN sakila.film_category fc
  ON fa.film_id = fc.film_id
LEFT JOIN sakila.category c
  ON fc.category_id = c.category_id
GROUP BY a.actor_id, a.first_name, a.last_name;

--
-- Procedure structure for procedure `rewards_report`
--

DELIMITER //

CREATE PROCEDURE rewards_report (
    IN min_monthly_purchases TINYINT UNSIGNED
    , IN min_dollar_amount_purchased DECIMAL(10,2)
    , OUT count_rewardees INT
)
LANGUAGE SQL
NOT DETERMINISTIC
READS SQL DATA
SQL SECURITY DEFINER
COMMENT 'Provides a customizable report on best customers'
proc: BEGIN

    DECLARE last_month_start DATE;
    DECLARE last_month_end DATE;

    /* Some sanity checks... */
    IF min_monthly_purchases = 0 THEN
        SELECT 'Minimum monthly purchases parameter must be > 0';
        LEAVE proc;
    END IF;
    IF min_dollar_amount_purchased = 0.00 THEN
        SELECT 'Minimum monthly dollar amount purchased parameter must be > $0.00';
        LEAVE proc;
    END IF;

    /* Determine start and end time periods */
    SET last_month_start = DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);
    SET last_month_start = STR_TO_DATE(CONCAT(YEAR(last_month_start),'-',MONTH(last_month_start),'-01'),'%Y-%m-%d');
    SET last_month_end = LAST_DAY(last_month_start);

    /*
        Create a temporary storage area for
        Customer IDs.
    */
    CREATE TEMPORARY TABLE tmpCustomer (customer_id SMALLINT UNSIGNED NOT NULL PRIMARY KEY);

    /*
        Find all customers meeting the
        monthly purchase requirements
    */
    INSERT INTO tmpCustomer (customer_id)
    SELECT p.customer_id
    FROM payment AS p
    WHERE DATE(p.payment_date) BETWEEN last_month_start AND last_month_end
    GROUP BY customer_id
    HAVING SUM(p.amount) > min_dollar_amount_purchased
    AND COUNT(customer_id) > min_monthly_purchases;

    /* Populate OUT parameter with count of found customers */
    SELECT COUNT(*) FROM tmpCustomer INTO count_rewardees;

    /*
        Output ALL customer information of matching rewardees.
        Customize output as needed.
    */
    SELECT c.*
    FROM tmpCustomer AS t
    INNER JOIN customer AS c ON t.customer_id = c.customer_id;

    /* Clean up */
    DROP TABLE tmpCustomer;
END //

DELIMITER ;

DELIMITER $$

CREATE FUNCTION get_customer_balance(p_customer_id INT, p_effective_date DATETIME) RETURNS DECIMAL(5,2)
    DETERMINISTIC
    READS SQL DATA
BEGIN

       #OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
       #THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
       #   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
       #   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
       #   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
       #   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED

  DECLARE v_rentfees DECIMAL(5,2); #FEES PAID TO RENT THE VIDEOS INITIALLY
  DECLARE v_overfees INTEGER;      #LATE FEES FOR PRIOR RENTALS
  DECLARE v_payments DECIMAL(5,2); #SUM OF PAYMENTS MADE PREVIOUSLY

  SELECT IFNULL(SUM(film.rental_rate),0) INTO v_rentfees
    FROM film, inventory, rental
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

  SELECT IFNULL(SUM(IF((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) > film.rental_duration,
        ((TO_DAYS(rental.return_date) - TO_DAYS(rental.rental_date)) - film.rental_duration),0)),0) INTO v_overfees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;


  SELECT IFNULL(SUM(payment.amount),0) INTO v_payments
    FROM payment

    WHERE payment.payment_date <= p_effective_date
    AND payment.customer_id = p_customer_id;

  RETURN v_rentfees + v_overfees - v_payments;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE film_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT)
READS SQL DATA
BEGIN
     SELECT inventory_id
     FROM inventory
     WHERE film_id = p_film_id
     AND store_id = p_store_id
     AND inventory_in_stock(inventory_id);

     SELECT COUNT(*)
     FROM inventory
     WHERE film_id = p_film_id
     AND store_id = p_store_id
     AND inventory_in_stock(inventory_id)
     INTO p_film_count;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE film_not_in_stock(IN p_film_id INT, IN p_store_id INT, OUT p_film_count INT)
READS SQL DATA
BEGIN
     SELECT inventory_id
     FROM inventory
     WHERE film_id = p_film_id
     AND store_id = p_store_id
     AND NOT inventory_in_stock(inventory_id);

     SELECT COUNT(*)
     FROM inventory
     WHERE film_id = p_film_id
     AND store_id = p_store_id
     AND NOT inventory_in_stock(inventory_id)
     INTO p_film_count;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION inventory_held_by_customer(p_inventory_id INT) RETURNS INT
READS SQL DATA
BEGIN
  DECLARE v_customer_id INT;
  DECLARE EXIT HANDLER FOR NOT FOUND RETURN NULL;

  SELECT customer_id INTO v_customer_id
  FROM rental
  WHERE return_date IS NULL
  AND inventory_id = p_inventory_id;

  RETURN v_customer_id;
END $$

DELIMITER ;

DELIMITER $$

CREATE FUNCTION inventory_in_stock(p_inventory_id INT) RETURNS BOOLEAN
READS SQL DATA
BEGIN
    DECLARE v_rentals INT;
    DECLARE v_out     INT;

    #AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
    #FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED

    SELECT COUNT(*) INTO v_rentals
    FROM rental
    WHERE inventory_id = p_inventory_id;

    IF v_rentals = 0 THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(rental_id) INTO v_out
    FROM inventory LEFT JOIN rental USING(inventory_id)
    WHERE inventory.inventory_id = p_inventory_id
    AND rental.return_date IS NULL;

    IF v_out > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END $$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


