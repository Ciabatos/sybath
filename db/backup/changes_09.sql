CREATE OR REPLACE FUNCTION attributes.get_other_player_stats(p_player_id integer, p_other_player_id text)
 RETURNS TABLE(stat_id integer, value integer, name character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN

 RETURN QUERY
 SELECT 
    t1.stat_id,
    t1.value,
    t2.name
   FROM players.players p
   JOIN attributes.player_stats t1 ON p.id = t1.player_id
   JOIN knowledge.known_players_stats kps ON kps.player_id = p_player_id
                                          AND kps.other_player_id = t1.player_id
   JOIN attributes.stats t2 ON t1.stat_id = t2.id
WHERE p.id = players.get_real_player_id(p_other_player_id)
AND ( kps.expires_at IS NULL OR kps.expires_at >= NOW() )
ORDER BY t1.id;

END;

$function$
;

COMMENT ON FUNCTION "attributes".get_other_player_stats(int4, text) IS 'get_api';
