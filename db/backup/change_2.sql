-- DROP FUNCTION squad.get_squad_invites(int4);

CREATE OR REPLACE FUNCTION squad.get_squad_invites(p_player_id integer)
 RETURNS TABLE(id integer, squad_id integer, squad_name character varying, name character varying, nickname character varying, second_name character varying, created_at timestamp without time zone, map_id integer, map_tile_x integer, map_tile_y integer)
 LANGUAGE plpgsql
AS $function$
      BEGIN

            RETURN QUERY
           SELECT si.id, s.id AS squad_id, s.squad_name, p."name" ,p.nickname , p.second_name , si.created_at ,mtsp.map_id, mtsp.map_tile_x ,mtsp.map_tile_y  
            FROM squad.squad_invites si
            JOIN squad.squads s ON si.squad_id = s.id
            JOIN players.players p ON p.id = si.inviter_player_id 
            JOIN world.map_tiles_squads_positions mtsp ON mtsp.squad_id = s.id 
            WHERE si.invited_player_id = p_player_id
            AND si.status IN (1,2);


      END;
      $function$
;

COMMENT ON FUNCTION squad.get_squad_invites(int4) IS 'get_api';
