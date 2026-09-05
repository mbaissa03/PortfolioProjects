SELECT *
FROM world_layoffs.layoffs_staging2;

#Identify the highest total and percentage layoffs - 1 represents 100% of the employees
#were laid off (i.e., the company went under)
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging2; 

#Identify companies that no longer exist (percentage laid off = 1)
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

#Find which company had the largest layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

#Find the date ranges for the layoffs
SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs.layoffs_staging2;

#Identify the industries with the largest layoffs
SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

#Find the total layoffs by country
SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

#View the layoffs by year
SELECT YEAR(`date`) AS Layoff_Year, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY Layoff_year
ORDER BY Layoff_year DESC;

#Layoffs by company stage
SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY SUM(total_laid_off) DESC;

#Compute the rolling total of company layoffs 
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH rolling_sum_cte AS
(
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS TOTAL_LAID_OFF
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, TOTAL_LAID_OFF AS LAID_OFF_MONTHLY, SUM(TOTAL_LAID_OFF) OVER(ORDER BY `MONTH`) AS ROLLING_TOTAL
FROM rolling_sum_cte
;
