DROP FUNCTION squad.get_active_player_squad_players_profiles(int4);

CREATE OR REPLACE FUNCTION squad.get_squad_players_profiles(p_player_id integer)
 RETURNS TABLE(other_player_id text, name character varying, second_name character varying, nickname character varying, image_map character varying, image_portrait character varying)
 LANGUAGE plpgsql
AS $function$
      BEGIN
            RETURN QUERY
            SELECT 
            p.id::text AS other_player_id,
            p.name,
            p.second_name,
            p.nickname,
            p.image_map,
            p.image_portrait
            FROM players.players p
            JOIN squad.squad_players sp ON p.id = sp.player_id
                                        AND sp.squad_id = (SELECT squad_id FROM squad.get_active_player_squad(p_player_id));
      END;
      $function$
;

COMMENT ON FUNCTION squad.get_squad_players_profiles(int4) IS 'get_api';
