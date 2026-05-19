DROP FUNCTION players.discover_other_player_profile(int4, text);

CREATE OR REPLACE FUNCTION knowledge.discover_other_player_profile(p_player_id integer, p_other_player_id text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_other_player_id integer;
BEGIN

SELECT p.id
INTO v_other_player_id
FROM players.players p
WHERE p.id = players.get_real_player_id(p_other_player_id)
AND p.id NOT IN (SELECT other_player_id FROM knowledge.known_players_profiles WHERE player_id = p_player_id)
LIMIT 1;

IF v_other_player_id IS NOT NULL THEN

    INSERT INTO knowledge.known_players_profiles
    (player_id, other_player_id)
    VALUES(p_player_id, v_other_player_id);

END IF;

END;
$function$
;
