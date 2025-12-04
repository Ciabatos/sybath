-- DROP PROCEDURE players.add_player_ability(int4, int4, int4);

CREATE OR REPLACE FUNCTION attributes.add_player_ability(IN p_player_id integer, IN p_ability_id integer, IN p_value integer)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
AS $function$
BEGIN
    INSERT INTO attributes.player_abilities(player_id, ability_id, value)
    VALUES (p_player_id, p_ability_id, p_value);
    RETURN QUERY SELECT 'ok', FORMAT('Added ability %s to player %s', p_ability_id, p_player_id);
EXCEPTION WHEN unique_violation THEN
    RETURN QUERY SELECT 'fail', FORMAT('Player %s already has ability %s', p_player_id, p_ability_id);
END;
$function$
;


