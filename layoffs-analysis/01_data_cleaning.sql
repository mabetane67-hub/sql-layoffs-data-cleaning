-- Data cleaning project 

-- 1)Removing duplicates 
-- 2)Standerdize the data 
-- 3)Null values or blank values 
-- 4)Remove any columns 


SELECT * 
FROM world_layoffs.layoffs;

-- It's better to create a new table to work on and let the main table untouched and work in the second table 

-- 1)Removing duplicates 

create table layoffs_staging 
like layoffs 
;

select *
from layoffs_staging
;


insert into layoffs_staging 
select *
from layoffs
;

-- for next step since now we have similar table to the main one 
-- we will creat a new column wich is used to identify duplicates by showing if there is any duplicates


select *,
row_number() over( partition by company,location,
industry,total_laid_off,percentage_laid_off,`date`,stage,
country,funds_raised_millions) as row_num
FROM layoffs_staging 
;


-- Now we should find where we have the duplicates 
-- Thats why wer will need a cte to identify those duplicates 



with duplicates as 
(
select *,
row_number() over(partition by company,location,
industry,total_laid_off,percentage_laid_off,`date`,stage,
country,funds_raised_millions) as row_num
FROM layoffs_staging 
)
select*
from duplicates
where row_num > 1 
;


-- i will check by typing the name if those 5 comapny we got 

select *
from layoffs_staging
where company = "Cazoo"
;

-- we want to delete those duplicates but i see that we should another table to delete because its a cte and we can't delete directly from a cte 


with duplicates as 
(
select *,
row_number() over(partition by company,location,
industry,total_laid_off,percentage_laid_off,`date`,stage,
country,funds_raised_millions) as row_num
FROM layoffs_staging 
)
delete
from duplicates
where row_num > 1 ;

-- We have many ways to create new table and this is one of theme 
-- i copied the create statement from layoffs_staging and i added that extra row "rom_num"


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from layoffs_staging2;

-- Here i added the informations  



insert into layoffs_staging2
select *,
row_number() over(partition by company,location,
industry,total_laid_off,percentage_laid_off,`date`,stage,
country,funds_raised_millions) as row_num
FROM layoffs_staging;

-- Now we can delete easly 
delete
from layoffs_staging2
where row_num > 1;


select *
from layoffs_staging2
where row_num > 1;

-- That's everything for this part now let's move to next step which is...


-- 2) Standerdazing data 

-- first thing we have here is the space on the first 2 rows of the company column 

select *
from layoffs_staging2;

select company, trim(company)
from layoffs_staging2;

-- now we use the update function to make the change into our table 
update layoffs_staging2
set company = trim(company);

-- We will run this to see if there is any industry where there a similarity to make it standar 
 
select distinct industry 
from layoffs_staging2
order by industry;

-- We got "crypto" and "crypto currency" which is the same thing
select *
from layoffs_staging2
where industry like 'Crypto%';

-- We are making it one industry 

update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- Now i will take a look at different columns to check if there is any issue

select distinct location 
from layoffs_staging2
order by 1;

select distinct country
from layoffs_staging2
order by 1;

-- I noticed that i have a problem is United States  that should be fixed 


select *
from layoffs_staging2
where country like 'United States%'
order by 1;

-- Now we will update to 'United States' to make it just one country 

update layoffs_staging2
set country = 'United States'
where country like 'United States%'
;

select `date`,
str_to_date(`date`,'%m/%d/%Y') 
from layoffs_staging2;

-- we have column date to be in date form not text like we have it 

update layoffs_staging2
set `date` = str_to_date(`date`,'%m/%d/%Y') ;

-- We will use this to change to date in  in our table 

alter table layoffs_staging2
modify column  `date` date;

-- 3)Null values or blank values 

select *
from layoffs_staging2
where industry is null or industry = '';

select*
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null  ;


update layoffs_staging2
set industry = null
where industry = '';

select *
from layoffs_staging2
where industry is null 
;

select *
from layoffs
where company = 'Airbnb';


select t1.company, t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
where (t1.industry is null  )
and t2.industry is not null 
;


update layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null;




select *
from layoffs_staging2
where company = 'Airbnb';

select*
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null  ;


-- 4)Remove any columns 


delete 
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null  ;

alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2;

-- This column down here should be a float number to be more specifique 

alter table layoffs_staging2
modify column funds_raised_millions float;

-- I don't know why id didn't but i run it i guess it's like that from the origine 
select *
from layoffs_staging2;
































































































































