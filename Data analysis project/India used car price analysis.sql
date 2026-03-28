-- TITLE:USED CAR PRICE ANALISIS
 
 
-- DATA IMPORT 
use car_price_analysys;

select * from used_car_dataset;

/*DATA UNDERSTANT */

-- 1.TABLE STUCTUER or DATA TYPES
describe used_car_dataset;
          -- OR
SHOW COLUMNS  FROM used_car_dataset;

-- 2.SAMPLE DATA 
SELECT * from used_car_dataset
limit 5;

-- 3.TOTEL ROWS COUNT 
select count(*) from used_car_dataset;



 -- 4.NULL values CHEKE
SELECT 
COUNT(*) - COUNT(car_name) AS car_name_nulls,
COUNT(*) - COUNT(car_price_in_rupees) AS price_nulls,
COUNT(*) - COUNT(kms_driven) AS kms_nulls,
COUNT(*) - COUNT(fuel_type) AS fuel_nulls,
COUNT(*) - COUNT(city) AS city_nulls
FROM used_car_dataset;

        -- OR
        
SELECT * FROM used_car_dataset
WHERE car_name IS NULL
   OR car_price_in_rupees IS NULL
   OR kms_driven IS NULL
   OR fuel_type IS NULL
   OR city IS NULL;
   
        -- OR
        
SELECT
SUM(car_name IS NULL) AS car_name_nulls,
SUM(car_price_in_rupees IS NULL) AS price_nulls,
SUM(kms_driven IS NULL) AS kms_nulls
FROM  used_car_dataset ;

-- 5.some time not null but get emty and cheke
SELECT
SUM(car_name = '') AS car_name_empty,
SUM(car_price_in_rupees = '') AS price_empty,
SUM(kms_driven = '') AS kms_empty
FROM used_car_dataset;


-- 6.unique of all columns

SELECT 
COUNT(DISTINCT car_name) AS car_name_unique,
COUNT(DISTINCT car_price_in_rupees) AS price_unique,
COUNT(DISTINCT kms_driven) AS kms_unique,
COUNT(DISTINCT fuel_type) AS fuel_unique,
COUNT(DISTINCT city) AS city_unique,
COUNT(DISTINCT year_of_manufacture) AS year_unique
FROM used_car_dataset ;





/* DATA CLEANING*/

--  IF have missing value dro or fill
-- Check for missing values
SELECT 
    COUNT(*) - COUNT(car_price_int) AS missing_price,
    COUNT(*) - COUNT(kms_driven_int) AS missing_kms,
    COUNT(*) - COUNT(fuel_type) AS missing_fuel_type,
    COUNT(*) - COUNT(city) AS missing_city,
    COUNT(*) - COUNT(brand) AS missing_brand
FROM used_car_dataset;

-- if have null value dro or fill
-- if have  empty values ('') drope or fill


-- CHANGE COLUMNS TEXT TO  INTIGER 
 -- 1. ADD NEW COLUM to kms_driven
ALTER TABLE used_car_dataset
ADD COLUMN kms_driven_int INT;

-- 2.text  to intiger tranfer 
UPDATE used_car_dataset
SET kms_driven_int = CAST(REPLACE(REPLACE(kms_driven, ',', ''), ' km', '') AS UNSIGNED);

-- 3. chek the result
SELECT kms_driven, kms_driven_int
FROM used_car_dataset
LIMIT 10;

-- 4. drope old text column
alter table used_car_dataset
drop column kms_driven ;

-- 1. add column to car price text to intiger

ALTER TABLE used_car_dataset
ADD COLUMN car_price_int BIGINT;

-- 2. modify the columen 

ALTER TABLE used_car_dataset 
MODIFY COLUMN car_price_int BIGINT;

-- 3.update the colume
UPDATE used_car_dataset
SET car_price_int = CASE
    WHEN car_price_in_rupees LIKE '%Lakh%' THEN 
        ROUND(REPLACE(REPLACE(REPLACE(car_price_in_rupees, ',', ''), 'Lakh', ''), ' ', '') * 100000)
    WHEN car_price_in_rupees LIKE '%Crore%' THEN 
        ROUND(REPLACE(REPLACE(REPLACE(car_price_in_rupees, ',', ''), 'Crore', ''), ' ', '') * 10000000)
    ELSE 
        ROUND(REPLACE(car_price_in_rupees, ',', '')) -- simple number with commas
END;

 -- 4.cheke the result
SELECT car_price_in_rupees, car_price_int
FROM used_car_dataset
LIMIT 10;

-- 5.drop the old car price column 
ALTER TABLE used_car_dataset
DROP COLUMN car_price_in_rupees ;

-- CHEKE DUPLICAT ROW

select* from used_car_dataset
group by car_name ,car_price_in_rupees,kms_driven,fuel_type,city,year_of_manufacture
having count(*)>1;

-- 1.count of duplicat

select COUNT(*) FROM (
    SELECT car_name, car_price_in_rupees, kms_driven, fuel_type, city, year_of_manufacture
    FROM used_car_dataset
    GROUP BY car_name, car_price_in_rupees, kms_driven, fuel_type, city, year_of_manufacture
    HAVING COUNT(*) > 1
)  AS duplicate_rows;

-- 2.drope the duplicat 

CREATE TABLE used_car_clean AS
SELECT DISTINCT *
FROM used_car_dataset;

DROP TABLE used_car_dataset;

 RENAME TABLE used_car_clean TO used_car_dataset;
  
  --  3.after drop check the  table 
select COUNT(*) FROM (
    SELECT car_name, car_price_in_rupees, kms_driven, fuel_type, city, year_of_manufacture
    FROM used_car_dataset
    GROUP BY car_name, car_price_in_rupees, kms_driven, fuel_type, city, year_of_manufacture
    HAVING COUNT(*) > 1
)  AS duplicate_rows;

--  set lower or upper case the text data columns  get wrong analysis
UPDATE used_car_dataset 
SET city = LOWER(city);

UPDATE used_car_dataset 
SET fuel_type = LOWER(fuel_type), car_name = LOWER(car_name);

select * from used_car_dataset ;

-- #trim  this is use for excra spaces like '  maruti suzuki swift  ' to 'maruti suzuki swift'
UPDATE used_car_dataset
SET 
car_name = TRIM(car_name),
fuel_type = TRIM(fuel_type),
city = TRIM(city);

-- after cheke the trim is right
SELECT fuel_type
FROM used_car_dataset
WHERE fuel_type LIKE ' %' OR fuel_type LIKE '% ';

-- chek inviled data like 1800 year and 3000 year  also outliers example price 9000000  in data analyze
SELECT *
FROM used_car_dataset
WHERE year_of_manufacture < 2004
   OR year_of_manufacture > 2026;

-- if have date  data Convert date column to datetime

-- Create brand column (first word)
ALTER TABLE used_car_dataset ADD brand VARCHAR(50);
UPDATE used_car_dataset
SET brand = SUBSTRING_INDEX(car_name, ' ', 1);

-- Create model column (rest of the string after first space)

ALTER TABLE used_car_dataset ADD model VARCHAR(80);

-- Update model column with remaining string
UPDATE used_car_dataset
SET model = TRIM(SUBSTRING(car_name, LENGTH(brand) + 2));

-- Verify
SELECT car_name, brand, model
FROM used_car_dataset
LIMIT 10;

-- DROP THE ORIGNAL COLUMN


-- put brand and model in   column number 1 and 2
ALTER TABLE used_car_dataset
MODIFY COLUMN brand VARCHAR(50) FIRST;

ALTER TABLE used_car_dataset
MODIFY COLUMN model VARCHAR(150) AFTER brand;

--  after drop column
ALTER table  used_car_dataset
drop column car_name;  

-- creat car age column 
ALTER TABLE used_car_dataset
ADD car_age INT;


UPDATE used_car_dataset
SET car_age = 2024 - year_of_manufacture;

--  'diesel + 1' and  'diesel' same fule that reason both convert 
UPDATE used_car_dataset
SET fuel_type = CASE
    WHEN fuel_type = 'diesel + 1' THEN 'diesel'
    WHEN fuel_type = 'petrol + 1' THEN 'petrol'
    ELSE fuel_type
END;
 
 -- chethisi conver is good 
 SELECT fuel_type, COUNT(*)
FROM used_car_dataset
GROUP BY fuel_type
ORDER BY fuel_type;


 --   FINAL VIEW 
 
 SELECT * FROM used_car_dataset;
 
 
 
/*DESCRIPTIVE ANALYZE*/

-- 1. descripe of car_price_int
select sum(car_price_int), 
	   max(car_price_int),
       min(car_price_int),
       avg(car_price_int),
       count(car_price_int) from used_car_dataset; 

-- 2.describe of kms_driven_int
select sum(kms_driven_int), 
	   max(kms_driven_int),
       min(kms_driven_int),
       avg(kms_driven_int),
       count(kms_driven_int) from used_car_dataset; 
       
-- 3.describe of year_of_manufacture
select  
	   max(year_of_manufacture),
       min(year_of_manufacture),
       count(year_of_manufacture) from used_car_dataset; 



SELECT * from used_car_dataset; 

-- 1. brand wise car price 
select brand, avg(car_price_int)as avgcar_price, avg(car_age)as avgcar_age  from used_car_dataset
group by brand 
order by avgcar_price,avgcar_age ; 
 
 --   city wise car price 
select city,round( avg(car_price_int),0) as avgcar_price  from used_car_dataset
group by city 
order by avgcar_price  ; 



-- fyle type wise car price 
select fuel_type,round( avg(car_price_int),0) as avgcar_price from used_car_dataset
group by fuel_type
order by avgcar_price ; 

-- km wise car price
select kms_driven_int,round( avg(car_price_int),0) as avgcar_price from used_car_dataset
group by kms_driven_int 
order by avgcar_price; 

-- year_of_manufactur wise car price 
select car_age,round( avg(car_price_int),0) as avgcar_price from used_car_dataset
group by car_age
order by avgcar_price;

-- model wise car price 
select model,round( avg(car_price_int),0) as avgcar_price from used_car_dataset
group by model
order by avgcar_price;

-- distibution  / Count of Cars per column


-- 1. car price distubution in count
SELECT FLOOR(car_price_int / 100000) AS price_lakh_range,COUNT(*) AS car_count
FROM used_car_dataset
GROUP BY price_lakh_range
ORDER BY price_lakh_range;

-- 2. fule type  distubution in count
SELECT fuel_type ,COUNT(*) AS car_count FROM used_car_dataset
GROUP BY fuel_type
ORDER BY fuel_type;

-- 3. city distubution in count
SELECT city ,COUNT(*) AS car_count FROM used_car_dataset
GROUP BY city
ORDER BY city;

-- 4. brand distubution in count
SELECT brand ,COUNT(*) AS car_count FROM used_car_dataset
GROUP BY brand
ORDER BY brand;
--  car age distubution in count
SELECT car_age , COUNT(*) AS car_count
FROM used_car_dataset
GROUP BY car_age
ORDER BY car_age;

-- Top 5 Expensive Cars
SELECT * FROM used_car_dataset
ORDER BY car_price_int DESC
LIMIT 5;

-- Top 5 chep Cars
SELECT * FROM used_car_dataset
ORDER BY car_price_int ASC
LIMIT 5;

-- Fuel Type vs Avg Kms Driven
SELECT fuel_type, ROUND(AVG(kms_driven_int),0) AS avg_kms
FROM used_car_dataset
GROUP BY fuel_type
order by avg_kms;

-- City vs Avg Car Age
SELECT city, ROUND(AVG(car_age),1) AS avg_car_age 
FROM used_car_dataset
GROUP BY city
ORDER BY avg_car_age DESC;

-- dignostig analisis 


select brand, avg(car_price_int) as avgcar_price ,car_age from used_car_dataset
group by brand ,car_age
order by  brand, avgcar_price; 



select brand,model, avg(car_price_int) as avgcar_price ,car_age from used_car_dataset
group by brand,model ,car_age
order by  brand,model, avgcar_price; 

select brand,fuel_type, avg(car_price_int) as avgcar_price ,car_age from used_car_dataset
group by brand,fuel_type ,car_age
order by  brand,fuel_type, avgcar_price;


