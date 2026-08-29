-- Exploratory Data Analysis (EDA)

-- First things first, we pull the table to inspect it

select *
from layoffs_staging2
;

-- I'll start with some simple aggregate functions first

select
	   min(total_laid_off) as smallest_laid_off,
       max(total_laid_off) as biggest_laid_off,
	   sum(total_laid_off) as sum_laid_off,
       avg(total_laid_off) as avg_laid_off
from layoffs_staging2
;

-- I notice there's a big difference between the smallest and largest single layoff event

-- Now let's see the top 10 biggest layoffs, excluding nulls

select company,industry,`date`,total_laid_off
from layoffs_staging2
where total_laid_off is not null 
order by total_laid_off desc
limit 10 
;

-- Google has the single largest layoff event (12,000 people)
-- and most of the biggest events cluster around late 2022 and early 2023

-- Now let's take a look at the smallest layoffs

select company, industry, `date`,total_laid_off
from layoffs_staging2
where total_laid_off is not null 
order by total_laid_off asc
limit 10
;

-- The companies here aren't well-known ones
-- and the numbers laid off are all under 10 people, very small compared to the top end
-- and all of these happened in 2020, right at the start of COVID


-- Now let's see the companies that laid off all of their employees

select company, percentage_laid_off, stage, total_laid_off
from layoffs_staging2
where percentage_laid_off = 1
order by total_laid_off desc
;

-- 116 companies laid off 100% of their employees,
-- a small share overall but still a striking number of full shutdowns
-- they range across company sizes: small, medium, and large
-- I left the date out of this query since it doesn't add much here


select industry,sum(total_laid_off) as total_laid_off , count(*) layoff_events
from layoffs_staging2
group by industry 
order by total_laid_off desc
;

-- this is a useful breakdown of total layoffs by industry
-- Consumer comes out on top by total people laid off
-- Retail takes second place

 
-- now let's see the same breakdown by company

select company,sum(total_laid_off) as total_laid_off , count(*) layoff_events
from layoffs_staging2
group by company
order by total_laid_off desc
;

-- I expected Google to be in first place
-- but Amazon takes first place because it had 3 separate layoff events that add up together
-- Google and Meta each only have one recorded layoff event, and those two events
-- happen to be close in size (12,000 vs 11,000)


-- now let's look at company stage

select stage,sum(total_laid_off) as total_laid_off , count(*) layoff_events
from layoffs_staging2
group by stage
order by total_laid_off desc
;

-- the 'Post-IPO' stage takes the top spot with a total of about 205k people laid off,
-- far more than any other single stage

-- now let's try countries

select country ,sum(total_laid_off) as total_laid_off , count(*) layoff_events
from layoffs_staging2
group by country
order by total_laid_off desc
;

-- 'United States' has by far the largest number of layoffs at 
-- about 256,559 people, well ahead of any other country



select *
from layoffs_staging2
where total_laid_off is not null 
order by funds_raised_millions desc
limit 20 
;


-- Netflix has by far the highest funds raised, with a small total_laid_off number
-- compared to companies with similar or even lower funding
-- note: Netflix shows up multiple times here since funds_raised_millions is a fixed
-- value per company that repeats on each of its rows, not something set per event

select  substring(`date`,1 ,7) as month, SUM(total_laid_off) as total_laid_off
from  layoffs_staging2
where date is not null 
group by month
order by month
;

-- layoffs rocket from about 10,000 to nearly 27,000 in a single month (March to April 2020),
-- the initial COVID shock
-- they drop off fast and stay low and choppy through all of 2021
-- then start climbing again in early 2022 and keep building through mid-year
-- there's a dip in September 2022, then a sharp jump again toward the end of 2022 and into January 2023



with monthly as 
(
select  substring(`date`,1 ,7) as month, SUM(total_laid_off) as total_laid_off
from  layoffs_staging2
where date is not null 
group by month
order by month
)
select month,
	   total_laid_off,
       sum(total_laid_off) over(order by month) as rolling_total
from monthly 
order by month
;

-- I used this CTE with a window function to get a 'rolling_total', which adds each
-- month's total on top of the running total so far, until it reaches the grand total
-- across the whole period
-- over this ~3 year period, the rolling total climbs from around 10,000 up to
-- approximately 383,159 people laid off in total
-- this is a really useful technique for EDA, since it lets you compare growth
-- year over year, or across any custom time window, depending on the table


with company_rank as
(
select company, year(`date`) as years , sum(total_laid_off) as total_laid_off
from layoffs_staging2
group by company, years
),company_year_rank as 
(
select *,
	   dense_rank() over(partition by years order by total_laid_off desc) as ranking
from company_rank
where years is not null 
)
select *
from company_year_rank 
where ranking <= 5 
;



-- this gave us a lot to discuss
-- we have every year from 2020 to 2023, and for each year we picked the top 5
-- companies by total layoffs, ranked in descending order from highest to lowest
-- the companies change each year, but Amazon shows up in the top 5 for two years
-- in a row (2022 and 2023)




