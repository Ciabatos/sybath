CREATE OR REPLACE FUNCTION world.get_player_movement_action_in_process(p_player_id int)
RETURNS TABLE(scheduled_at timestamp, x int, y int)
LANGUAGE plpgsql
AS $function$
BEGIN

    IF EXISTS (
        SELECT 1
        FROM tasks.tasks
        WHERE method_name = 'world.player_movement'
          AND status IN (1, 2)
          AND player_id = p_player_id
    ) THEN

	RETURN QUERY
	        SELECT
	            NULL AS scheduled_at,
				map_tile_x AS x,
				map_tile_y AS y
	        FROM
	            world.map_tiles_players_positions t1
	        WHERE player_id = p_player_id
	
      UNION ALL
	
			 SELECT
			     scheduled_at,
			     (method_parameters->>'x')::int AS x,
			     (method_parameters->>'y')::int AS y
			 FROM tasks.tasks
			 WHERE player_id = p_player_id
			   AND method_name = 'world.player_movement'
			AND status IN (1, 2)
			 ORDER BY scheduled_at ASC NULLS FIRST;

    END IF;
END;
$function$
;