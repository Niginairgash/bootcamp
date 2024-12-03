create type season_starts as(
			season integer,
			gp integer,
			pts real,
			reb real,
			ast real
)

create table players(
			player_name text,
			height text,
			college text,
			country text,
			draft_round text,
			draft_number text,
			season_starts season_starts[],
			current_season integer,
			primary key(player_name, current_season)
)
