CREATE OR REPLACE FUNCTION attributes.check_ability_requirements(IN p_player_id integer)
RETURNS TABLE(ability_id integer)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT DISTINCT ar.ability_id
    FROM attributes.ability_requirements ar
    JOIN (
        SELECT 'SKILL' AS requirement_type, skill_id AS requirement_id, value
        FROM attributes.player_skills 
        WHERE player_id = p_player_id

        UNION ALL

        SELECT 'STAT' AS requirement_type, stat_id AS requirement_id, value
        FROM attributes.player_stats
        WHERE player_id = p_player_id
    ) checks
    ON ar.requirement_type = checks.requirement_type
       AND ar.requirement_id = checks.requirement_id
       AND checks.value >= ar.min_value;
END;
$function$;
