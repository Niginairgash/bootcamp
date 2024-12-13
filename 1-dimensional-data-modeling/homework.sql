
 /*
An array of struct with the following fields:
	*film: The name of the film.
	*votes: The number of votes the film received.
	*rating: The rating of the film.
	*filmid: A unique identifier for each film.
*/
create type films as(
 	films text,
 	votes int4,
 	rating float4,
 	filmid text
 )

/*
quality_class: This field represents an actor's performance quality, determined by the average rating of movies of their most recent year. It's categorized as follows:
	*star: Average rating > 8.
	*good: Average rating > 7 and ≤ 8.
	*average: Average rating > 6 and ≤ 7.
	*bad: Average rating ≤ 6.
*/
 create type quality_class as enum('bad', 'average', 'good', 'star')

/*
DDL for actors table
*/
create table actors(
	actor text,
	actor_id text,
	year int4,
	films films[],
	quality_class quality_class,
	is_active boolean
)
insert into actors
with years as(
	select *
	from pg_catalog.generate_series(2000, 2024) as film_season
), p as(
	select 
		actor,
		min(year) as first_year
	from actor_films af 
	group by actor
), actors_and_season as(
	select *
	from p
	join years 
	on p.first_year <= years.film_season
), windowed as(
	select 
		aas.actor,
		aas.film_season,
		array_remove(
			array_agg(
				case 
					when aas.film_season is not null
					then row(
						af.film,
						af.votes,
						af.rating,
						af.filmid
					)::films
				end)
				over(partition by aas.actor order by coalesce(aas.film_season,  af.year)),
				null
		) as films
		
	from actors_and_season aas
	left join actor_films af 
	on aas.actor = af.actor
	and aas.film_season = af.year
	order by aas.actor, aas.film_season
),
static as(
	select
		max(actor) as actor,
		max(actorid) as actorid,
		max(year) as year
	from actor_films
	group by actor
)
select 
	w.actor,
	st.actorid,
	st.year,
	films,
	case 
		when (films[cardinality(films)]::films).rating > 8 then 'star'
		when (films[cardinality(films)]::films).rating > 7 then 'good'
		when (films[cardinality(films)]::films).rating > 6 then 'average'
		else 'bad'
	end::quality_class,
	w.film_season = year as is_active
	
from windowed w
join static st
on w.actor = st.actor
where w.film_season is not null

/*
DDL for actors_history_scd table
*/
create table actors_history_scd(
	actor text,
	quality_class quality_class,
	is_active boolean,
	start_date integer,
	end_date integer
)


