-- DROP FUNCTION world.get_known_players_positions(int4, int4);

CREATE OR REPLACE FUNCTION world.get_known_players_positions(p_map_id integer, p_player_id integer)
 RETURNS TABLE(x integer, y integer, other_players jsonb)
 LANGUAGE plpgsql
AS $function$
BEGIN

RETURN QUERY

WITH player_tiles_view_range AS (
    SELECT 
         mp.map_tile_x
         ,mp.map_tile_y
    FROM world.map_tiles_players_positions mp
    WHERE mp.player_id = p_player_id
      AND mp.map_id = p_map_id
    LIMIT 1
)

SELECT
    T1.x,
    T1.y,
    jsonb_agg(
        jsonb_build_object(
            'otherPlayerId',T1.otherPlayerId,
            'imageMap',T1.imageMap,
            'inSquad',T1.inSquad,
            'squadId',T1.squadId
        )
    ) AS other_players
    
FROM (

    
        SELECT
            COALESCE(MTSP.map_tile_x, mp.map_tile_x) AS x
            ,COALESCE(MTSP.map_tile_y, mp.map_tile_y) AS y
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS otherPlayerId
            ,COALESCE(S.squad_image_map, p.image_map) AS imageMap
            ,MTSP.squad_id IS NOT NULL AS inSquad
            ,S.id AS squadId
                    FROM world.map_tiles_players_positions mp
                    JOIN players.players p ON mp.player_id = p.id
                    JOIN player_tiles_view_range ptvr ON ptvr.map_tile_x = mp.map_tile_x
                                       AND ptvr.map_tile_y = mp.map_tile_y
                    LEFT JOIN knowledge.known_players_positions kp ON kp.other_player_id = p.id
                                                                    AND kp.player_id = p_player_id
                    LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                                   AND kpp.other_player_id = p.id
                    LEFT JOIN squad.squad_players SP ON SP.player_id = mp.player_id
                    LEFT JOIN squad.squads S ON S.id = SP.squad_id
                    LEFT JOIN world.map_tiles_squads_positions MTSP ON MTSP.squad_id = SP.squad_id
                    WHERE mp.map_id = p_map_id
                     AND mp.player_id != p_player_id          
UNION
        SELECT
            COALESCE(MTSP.map_tile_x, mp.map_tile_x) AS x
            ,COALESCE(MTSP.map_tile_y, mp.map_tile_y) AS y
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS otherPlayerId
            ,COALESCE(S.squad_image_map, p.image_map) AS imageMap
            ,MTSP.squad_id IS NOT NULL AS inSquad
            ,S.id AS squadId
                    FROM world.map_tiles_players_positions mp
                    JOIN players.players p ON mp.player_id = p.id
                    JOIN knowledge.known_players_positions kp ON kp.other_player_id = p.id
                    LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
                                                                   AND kpp.other_player_id = p.id
                    LEFT JOIN squad.squad_players SP ON SP.player_id = mp.player_id
                    LEFT JOIN squad.squads S ON S.id = SP.squad_id
                    LEFT JOIN world.map_tiles_squads_positions MTSP ON MTSP.squad_id = SP.squad_id
                    WHERE mp.map_id = p_map_id
                     AND kp.player_id = p_player_id
                     AND mp.player_id != p_player_id
					 AND ( kp.expires_at IS NULL OR kp.expires_at >= NOW() )
) T1
        GROUP BY
            T1.x,
            T1.y;

END;
$function$
;

COMMENT ON FUNCTION world.get_known_players_positions(int4, int4) IS 'get_api';
