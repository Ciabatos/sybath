-- DROP FUNCTION players.player_abilities(int4);

CREATE OR REPLACE FUNCTION attributes.get_player_abilities(p_player_id integer)
 RETURNS TABLE(ability_id integer, value integer, name character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN

 RETURN QUERY
 SELECT 
    t1.ability_id,
    t1.value,
    t2.name
   FROM attributes.player_abilities t1
     JOIN attributes.abilities t2 ON t1.ability_id = t2.id
  WHERE t1.player_id = p_player_id
    ORDER BY t1.id;
END;

$function$
;
