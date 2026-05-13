-- DROP FUNCTION "attributes".get_other_player_skills(int4, text);

CREATE OR REPLACE FUNCTION attributes.get_other_player_skills(p_player_id integer, p_other_player_id text)
 RETURNS TABLE(skill_id integer, value integer, name character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN

 RETURN QUERY
 SELECT 
    t1.skill_id,
    t1.value,
    t2.name
   FROM players.players p
   JOIN attributes.player_skills t1 ON p.id = t1.player_id
   JOIN knowledge.known_players_skills kps ON kps.player_id = p_player_id
                                          AND kps.other_player_id = t1.player_id
     JOIN attributes.skills t2 ON t1.skill_id = t2.id
WHERE p.id = players.get_real_player_id(p_other_player_id)
AND ( kps.expires_at IS NULL OR kps.expires_at >= NOW() )
ORDER BY t1.id;
    
END;
$function$
;

COMMENT ON FUNCTION "attributes".get_other_player_skills(int4, text) IS 'get_api';
