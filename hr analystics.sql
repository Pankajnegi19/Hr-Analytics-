create database ProjectHR;
use ProjectHR;
select * from hr;

alter table hr
change column ï»¿id emp_id varchar(20) null;

describe hr;

set sql_safe_updates = 0;

update hr
set birthdate = case
		when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
		when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
		else null
		end;

alter table hr
modify column birthdate date; 


-- change the date format and data type of hire_date column

update hr
set hire_date = case
		when birthdate like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
		when birthdate like '%-%' then date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
		else null
		end;

alter table hr
modify column hire_date date; 

-- change tyhe date fromat and datatype of termdate column

update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

update hr 
set termdate = null
where termdate = '';

-- create age column

alter table hr 
add column age int; 

update hr
set age =  timestampdiff(year, birthdate,curdate());

SELECT min(age), max(age)
from hr

-- 1.what is the gender breakdown of employees in the company

select gender, count(gender) as count
from hr
group by gender;

-- 2. what is the race breakdown of employees in the company

select race, count(*) as race
from hr
where termdate is null
group by race;

-- 3. what is the age distributuion of employess in the company

SELECT
	CASE
		WHEN age >=18 AND age <=24 THEN '18-24'
        WHEN age >=25 AND age <=34 THEN '25-34'
        WHEN age >=35 AND age <=44 THEN '35-44'
        WHEN age >=45 AND age <=54 THEN '45-54'
        WHEN age >=55 AND age <=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
count(*) AS count
FROM hr
WHERE termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

-- 4. How many employees work headquarter vs remote

select location, count(*)
from hr
where termdate is null
group by location;

-- 5. What is the average length of employment who have been terminated.
select * from hr 

select year(termdate)-year(hire_date)
from hr
where termdate is not null;

-- 6. How does the gender distributioon vary across the department and job titles.
select gender, department, jobtitle, count(*) as count
from hr 
where termdate is not null
group by gender,department,jobtitle
order by gender,department,jobtitle;

-- 7. What is the distribution of job titles across the company.


select jobtitle, count(*) as count
from hr 
group by jobtitle;

--  8. which department is the heigher turnover/termination rate.
select * from hr

select department,
	count(*) as total_count,
	count(case
			when termdate is not null and termdate <= curdate() then 1
			end) as termdate_count,
	round((count(case
			when termdate is not null and termdate <= curdate() then 1
			end)/count(*))*100,2) as termination_rate
from hr
group by department
order by termination_rate desc;


-- 9. What is the distribution of employees across location_state

select location_state, count(*) as count
from hr
where termdate is null
group by location_state;

-- 10. How has the company employee count changed over time based on hire and termination date.

select year,
		hires,
        terminations,
        hires-terminations as net_change,
        (terminations/hires)*100 as change_percent
	from(
			select year(hire_date) as year,
			count(*) as hires,
			sum(case
					when termdate is not null and termdate <= curdate() then 1
					end) as terminations
			from hr
			group by year(hire_date)) as subquery
group by year
order by year;

