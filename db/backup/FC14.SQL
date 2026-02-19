
CREATE OR REPLACE FUNCTION world.get_known_map_tiles(p_map_id integer, p_player_id integer)
RETURNS SETOF world.map_tiles 
LANGUAGE plpgsql
AS $function$
BEGIN

RETURN QUERY
 SELECT 
 T1.map_id,
 T1.x,
 T1.y,

 CASE WHEN T2.player_id IS NULL THEN NULL
	ELSE T1.terrain_type_id 
 END AS terrain_type_id,

 CASE WHEN T2.player_id IS NULL THEN NULL
	ELSE T1.landscape_type_id 
 END AS landscape_type_id

 FROM world.map_tiles T1
 LEFT JOIN knowledge.known_map_tiles T2 on T2.map_id = T1.map_id
									  AND T2.map_tile_x = T1.x
									  AND T2.map_tile_y = T1.y
WHERE T1.map_id = p_map_id
AND T2.player_id = p_player_id;

END;
$function$
;

COMMENT ON FUNCTION world.get_known_map_tiles(int4, int4) IS 'get_api';
