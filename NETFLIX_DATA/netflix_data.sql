create TABLE netflix_raw(
	show_id varchar(10) primary key,
	type varchar(10) NULL,
	title varchar(200) NULL,
	director varchar(250) NULL,
	"cast" varchar(1000) NULL,
	country varchar(150) NULL,
	date_added varchar(20) NULL,
	release_year int NULL,
	rating varchar(10) NULL,
	duration varchar(10) NULL,
	listed_in varchar(100) NULL,
	description varchar(500) NULL
) 


-- data cleaning
-- 1. Removing Duplicates
select show_id,count(*) from netflix_raw
group by show_id
having count(*)>1

-- There are no duplicates for the column show_id beacuse it is primary key
--  Finding duplicates in title column
select * from netflix_raw where (upper(title),type) in (select upper(title),type from netflix_raw group by upper(title),
	type having count(*)>1)

	
-- Removing duplicates considering anyone using row_number concept
delete from netflix_raw where show_id in (select show_id from (select * ,row_number() over(partition by upper(title),type order by show_id) as rn from netflix_raw)n 
	where rn=2)


	
-- Dividing Directors, Genre(Listed_in), Country,Cast into different tables
select show_id,trim(value) as cast
from netflix_raw,
unnest(string_to_array("cast",',')) as value
	
select show_id,trim(value) as cast
into netflix_cast
from netflix_raw,
unnest(string_to_array("cast",',')) as value

select show_id,type,title,cast(date_added as date) as date_added,release_year
,rating,case when duration is null then rating else duration end as duration,description
	into netflix_cleaned from netflix_raw




--netflix data analysis

/*1  for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both */

	select nd.director,count(distinct case when type='Movie' then n.show_id end) as no_of_movies,
	count(distinct case when type='TV Show' then n.show_id end) as no_of_shows from netflix_directors nd join netflix_cleaned n on n.show_id = nd.show_id
	group by nd.director
	having count(distinct n.type)>1

	select type from netflix_cleaned where show_id in(select show_id from netflix_directors where director='Abhishek Chaubey')
	
--2 which country has highest number of comedy movies 

select nc.country,count(ng.show_id) as no_of_movies from netflix_genres ng join netflix_country nc on ng.show_id=nc.show_id
	join netflix_cleaned n on n.show_id=ng.show_id
	where ng.genre='Comedies' and n.type='Movie'
	group by nc.country
	order by no_of_movies desc limit 1

Comedies

--3 for each year (as per date added to netflix), which director has maximum number of movies released
select * from(
SELECT nd.director,extract(year from n.date_added) AS yr,count(n.show_id) as cnt from netflix_directors nd
join netflix_cleaned n on n.show_id=nd.show_id
where n.type='Movie'
group by nd.director,extract(year from n.date_added)
order by nd.director,yr) t order by cnt desc

select * from netflix_cleaned where show_id in (select show_id from netflix_directors where director='S.S. Rajamouli')

--4 what is average duration of movies in each genre

select ng.genre,round(avg(cast(replace (n.duration,' min','')as int)),0) as avg_duration from netflix_cleaned n join netflix_genres ng on n.show_id=ng.show_id where type='Movie'
group by ng.genre order by ng.genre


--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them 

select nd.director,count(distinct case when ng.genre='Horror Movies' then ng.show_id end) as no_of_horror_movies,
	count(distinct case when ng.genre='Comedies' then ng.show_id end) as no_of_comedy_movies
	from netflix_genres ng join netflix_directors nd on ng.show_id=nd.show_id
	join netflix_cleaned n on n.show_id=ng.show_id where n.type='Movie' and ng.genre in ('Horror Movies','Comedies')
group by nd.director having count(distinct ng.genre)=2







