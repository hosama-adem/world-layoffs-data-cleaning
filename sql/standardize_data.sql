-- Trim company names
UPDATE layoffs_stagging2
SET company = TRIM(company);

-- Standardize industry names
UPDATE layoffs_stagging2
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- Clean country names
UPDATE layoffs_stagging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date format
UPDATE layoffs_stagging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_stagging2
MODIFY COLUMN `date` DATE;
