SQL Data Cleaning — Layoffs Dataset

Overview

This project cleans a raw dataset of global tech layoffs using MySQL. The raw data included duplicate rows, inconsistent text formatting, incorrect data types, and missing values. The goal was to take it from raw to analysis-ready without touching the original table.

Dataset:
https://www.kaggle.com/datasets/swaptr/layoffs-2022

What I did

Staged the data — copied the raw table into a staging table (layoffs_staging) so the original data stays untouched no matter what happens next.
 1) Removed duplicates — since there's no unique ID column, used ROW_NUMBER() partitioned across every column to flag exact-duplicate rows, then kept only the first occurrence of each.
 2) Standardized values — trimmed whitespace from company names, merged inconsistent category labels (e.g. "Crypto", "Crypto Currency", "CryptoCurrency" → Crypto), and fixed inconsistent country names (e.g. "United States." → United States).
 3) Fixed data types — converted date from text to a proper DATE column, and corrected funds_raised_millions from INT to FLOAT so decimal funding figures (e.g. $214.5M) aren't silently rounded off.
 4) Handled missing values — filled in missing industry values by matching other rows from the same company, then removed rows with no usable layoff data at all (total_laid_off and percentage_laid_off both null).

Decisions worth calling out
Midway through deduplication, I first tried deleting duplicates directly from a CTE built on ROW_NUMBER() — MySQL doesn't allow deleting through that kind of CTE. I switched to writing the numbered rows into a second table (layoffs_staging2) and deleting from there instead.
I caught that funds_raised_millions was originally typed as INT, which rounds off decimal funding values on insert. I corrected the column type so future data keeps its precision,but it turns out to stay the same as the orginal version.


Next step

Part 2 of this project runs exploratory analysis on the cleaned table — total layoffs by industry/year, biggest single layoffs, and a rolling monthly total using a window function.


Exploratory Data Analysis (EDA)

Key Findings
- Between March 2020 and March 2023, this dataset tracks roughly 386K layoffs
  across ~1,900 companies in 60+ countries.
  
- The single largest layoff event was Google's cut of 12,000 employees in
  January 2023; most of the largest individual events cluster in late 2022
  and early 2023.
  
- Consumer was the hardest-hit industry by total people laid off, followed
  by Retail.
  
- The Post-IPO company stage accounts for far more layoffs than any other
  single stage, at roughly 205K people.
  
- The United States was affected far more than any other country.
- 
- Amazon leads the company ranking not because of one massive cut, but
  because it had three separate layoff rounds that sum together; Google and
  Meta each had a single very large event (12,000 and 11,000 respectively).
  
- 116 companies (~5% of those in the dataset) shut down entirely, laying off
  100% of staff, ranging from small startups to well-funded mid-size firms.
  
- Layoffs came in two distinct waves: a sharp COVID-driven spike in
  March–April 2020, then a much larger, sustained wave that built through
  2022 and peaked around November 2022 and January 2023.
  
- Amazon appeared in the top 5 companies by layoffs for two consecutive
  years (2022 and 2023).

Tools Used
- MySQL
