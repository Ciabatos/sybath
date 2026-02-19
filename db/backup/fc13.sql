-- usunac automatic_api

--dodac 

CREATE TABLE knowledge.known_map_tiles (
	player_id int4 NOT NULL,
	map_id int4 NOT null,
	map_tile_x int4 NOT null,
	map_tile_y int4 NOT null
);



CREATE OR REPLACE FUNCTION world.get_known_map_region(p_map_id integer, p_player_id integer, p_region_type integer)
 RETURNS TABLE(region_id integer, map_id integer, map_tile_x integer,map_tile_y integer, region_name character varying, image_fill character varying, image_outline character varying )
 LANGUAGE plpgsql
AS $function$
BEGIN

	RETURN QUERY
	select 
	T1.region_id
	,T1.map_id 
	,T1.map_tile_x 
	,T1.map_tile_y 
	,T2."name" as region_name
	,T2.image_fill 
	,T2.image_outline 
	from world.map_tiles_map_regions T1
	join world.map_regions T2 on T1.region_id = T2.id  
	join world.region_types T3 on T2.region_type_id  = T3.id 
	join knowledge.known_map_tiles T4 on T4.map_id = T1.map_id
									  AND T4.map_tile_x = T1.map_tile_x
									  AND T4.map_tile_y = T1.map_tile_y
	where T3.ID = p_region_type
	AND T1.map_id = p_map_id
	AND T4.player_id = p_player_id;

END;
$function$
;

COMMENT ON FUNCTION world.get_known_map_region(int4, int4, int4) IS 'get_api';
