
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
   FROM attributes.player_skills t1
   JOIN knowledge.known_players_skills kps ON kps.player_id = p_player_id
                                          AND kps.other_player_id = t1.player_id
   JOIN attributes.stats t2 ON t1.skill_id = t2.id
   WHERE t1.player_id = players.get_real_player_id(p_other_player_id)
   AND kps.snapshot IS NULL

   UNION ALL

   SELECT
       x.skill_id,
       x.value,
       x.name
   FROM knowledge.known_players_skills kps,
        jsonb_to_recordset(kps.snapshot) AS x(skill_id integer, value integer, name varchar)
   WHERE kps.player_id = p_player_id
   AND kps.other_player_id = players.get_real_player_id(p_other_player_id)
   AND kps.snapshot IS NOT NULL;

END;
$function$
;

COMMENT ON FUNCTION "attributes".get_other_player_skills(int4, text) IS 'get_api';
