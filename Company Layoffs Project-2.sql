SELECT *
FROM world_layoffs.layoffs;

#Step 1 - Create a copy of raw data (for the case when columns are to be deleted/edited)
CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

INSERT world_layoffs.layoffs_staging
SELECT *
FROM world_layoffs.layoffs;

SELECT *
FROM world_layoffs.layoffs_staging;

#Step 2 - Remove duplicates
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM world_layoffs.layoffs_staging;

WITH CTE_layoffs
AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, 
location,
industry, 
total_laid_off, 
percentage_laid_off, 
`date`,
stage,
country,
funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging
)

SELECT *
FROM CTE_layoffs
WHERE row_num > 1;

CREATE TABLE world_layoffs.layoffs_staging2 (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT world_layoffs.layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY 
company, 
location,
industry, 
total_laid_off, 
percentage_laid_off, 
`date`,
stage,
country,
funds_raised_millions) AS row_num
FROM world_layoffs.layoffs_staging;

SELECT *
FROM world_layoffs.layoffs_staging2;

DELETE FROM world_layoffs.layoffs_staging2
WHERE row_num > 1;

#Step 3 - Standardize data (i.e., removing blank space, standardizing industry names

UPDATE world_layoffs.layoffs_staging2 
SET company = TRIM(company);

SELECT DISTINCT(industry) 
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

UPDATE world_layoffs.layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

SELECT DISTINCT(country)
FROM world_layoffs.layoffs_staging2
ORDER BY 1;

UPDATE world_layoffs.layoffs_staging2
SET country = 'United States'
WHERE country = 'United States.';

SELECT STR_TO_DATE(`date`, "%m/%d/%Y")
FROM world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE;

#Step 4 - Fix rows with missing data - i.e., companies who done multiple layoffs have their respective industry populated
#on some rows but not all
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NULL
AND total_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL OR industry = '';

SELECT T1.industry, T2.industry
FROM world_layoffs.layoffs_staging2 AS T1
JOIN world_layoffs.layoffs_staging2 AS T2
	ON T1.company = T2.company
    AND T1.location = T2.location
WHERE T1.industry = '' OR T1.industry IS NULL
AND T2.industry != '';

UPDATE world_layoffs.layoffs_staging2 AS T1
JOIN world_layoffs.layoffs_staging2 AS T2
	ON T1.company = T2.company
    AND T1.location = T2.location
SET T1.industry = T2.industry
WHERE T1.industry = ''
AND T2.industry != '' ;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE company = 'Airbnb';

DELETE FROM  world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE world_layoffs.layoffs_staging2
DROP row_num;















