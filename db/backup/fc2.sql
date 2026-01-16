DROP FUNCTION players.get_active_player(int4);

CREATE OR REPLACE FUNCTION players.get_active_player(p_user_id integer)
 RETURNS TABLE(id integer)
 LANGUAGE plpgsql
AS $function$
      BEGIN
            RETURN QUERY
            SELECT 
            t1.id
            FROM players.players t1
            WHERE t1.user_id = p_user_id
             AND t1.is_active = true
            LIMIT 1;
      END;
      $function$
;
