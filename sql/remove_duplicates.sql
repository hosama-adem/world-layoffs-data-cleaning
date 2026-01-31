CREATE TABLE layoffs_stagging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT,
  row_num INT
);

INSERT INTO layoffs_stagging2
SELECT *,
ROW_NUMBER() OVER(
  PARTITION BY company, location, industry, total_laid_off,
               percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_stagging;

DELETE
FROM layoffs_stagging2
WHERE row_num > 1;
