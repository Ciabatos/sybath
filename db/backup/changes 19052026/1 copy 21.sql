DROP FUNCTION squad.get_active_player_squad(int4);

CREATE OR REPLACE FUNCTION squad.get_squad(p_player_id integer)
 RETURNS TABLE(squad_id integer, squad_name character varying, squad_image_portrait character varying)
 LANGUAGE plpgsql
AS $function$
      BEGIN
            RETURN QUERY
            SELECT 
            s.id AS squad_id
            ,s.squad_name
            ,s.squad_image_portrait
            FROM squad.squads s
            JOIN squad.squad_players sp ON s.id = sp.squad_id
            WHERE sp.player_id = p_player_id
            LIMIT 1;


      END;
      $function$
;

COMMENT ON FUNCTION squad.get_squad(int4) IS 'get_api';
