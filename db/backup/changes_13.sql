CREATE OR REPLACE FUNCTION squad.get_other_squad_players_profiles(p_player_id integer, p_squad_id integer)
 RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_map character varying, image_portrait character varying)
 LANGUAGE plpgsql
AS $function$
      BEGIN
 
            SELECT 
             CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS other_player_id
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.name ELSE NULL END AS name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.second_name ELSE NULL END AS second_name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.nickname ELSE NULL END AS nickname
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.image_portrait ELSE NULL END AS image_portrait
            FROM players.players p
            JOIN squad.squad_players sp ON p.id = sp.player_id
                                        AND sp.squad_id = p_squad_id
            JOIN knowledge.known_players_squad_profiles kpsp ON kpsp.player_id = p_player_id
                                                             AND kpsp.squad_id = sp.squad_id
            LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                           AND kpp.other_player_id = p.id
		    WHERE kpsp.snapshot IS NULL

			UNION ALL

		    SELECT
		        x.other_player_id,
		        x.name,
		        x.second_name,
				x.nickname,
				x.image_portrait
		    FROM knowledge.known_players_squad_profiles kps,
		         jsonb_to_recordset(kps.snapshot) AS x(other_player_id text, name varchar, second_name varchar, nickname varchar, image_portrait varchar)
		    WHERE kps.player_id = p_player_id
		    AND kps.other_player_id = players.get_real_player_id(p_other_player_id)
		    AND kps.snapshot IS NOT NULL;

      END;
      $function$
;

COMMENT ON FUNCTION squad.get_other_squad_players_profiles(int4, int4) IS 'get_api';
