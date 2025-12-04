CREATE OR REPLACE FUNCTION attributes.unlock_player_abilities(IN p_player_id integer)
RETURNS TABLE(status text, message text, ability_id integer)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_ability_id INTEGER;
BEGIN

    FOR v_ability_id IN
        SELECT ability_id FROM attributes.check_ability_requirements(p_player_id)
    LOOP
        RETURN QUERY
        SELECT  a.status, a.message, v_ability_id
        FROM attributes.add_player_ability(
            p_player_id := p_player_id,
            p_ability_id := v_ability_id,
            p_value := 1
        ) AS a;
    END LOOP;
END;
$function$;
