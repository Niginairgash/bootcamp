with yeasterday as(
	select * from players p 
	where current_season = 1995
),
today as(
	select * from player_seasons ps 
	where season = 1996
)
select 
	coalesce(t.player_name, y.player_name) as player_name,
	coalesce(t.height, y.height) as height,
	coalesce(t.college, y.college) as college,
	coalesce(t.country, y.country) as country,
	coalesce(t.draft_year, y.draft_year) as draft_year,
	coalesce(t.draft_round, y.draft_round) as draft_round,
	coalesce(t.draft_number, y.draft_number) as draft_number,
	case when y.season_starts is null 
		then array[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_starts]
		else y.season_starts  || array[row(
			t.season,
			t.gp,
			t.pts,
			t.reb,
			t.ast
		)::season_starts]
	end as season_starts
from today t full outer join yeasterday y
	on t.player_name = y.player_name
	
SELECT
	player_name,
	(season_starts[CARDINALITY(season_starts)]::season_starts).pts /
	CASE 
		WHEN (season_starts[1]::season_starts).pts = 0 THEN 1
		ELSE (season_starts[1]::season_starts).pts 
	END
FROM players
WHERE current_season = 2001
order by 2 desc
