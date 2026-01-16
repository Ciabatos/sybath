CREATE OR REPLACE FUNCTION players.get_active_player_profile(p_player_id integer)
 RETURNS TABLE(name character varying, image_map character varying, image_portrait character varying)
 LANGUAGE plpgsql
AS $function$
      BEGIN
            RETURN QUERY
            SELECT 
			name,
			image_map,
			image_portrait
            FROM players.players t1
            WHERE t1.id = p_player_id
             AND t1.is_active = true
            LIMIT 1;
      END;
      $function$
;



COMMENT ON FUNCTION players.get_active_player_profile(int4) IS 'get_api';
