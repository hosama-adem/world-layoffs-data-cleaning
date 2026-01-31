-- Replace blank industry values with NULL
UPDATE layoffs_stagging2
SET industry = NULL
WHERE industry = '';

-- Fill missing industries using same company values
UPDATE layoffs_stagging2 t1
JOIN layoffs_stagging2 t2
  ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- Remove rows with no layoff data
DELETE
FROM layoffs_stagging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
