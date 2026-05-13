
CREATE OR REPLACE FUNCTION squad.discover_squad_profiles(p_player_id integer, p_other_squad_id integer, p_expire_after interval DEFAULT NULL::interval)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_expires_at timestamp;
BEGIN

    IF p_other_squad_id IS NULL THEN
        RETURN;
    END IF;

    v_expires_at := CASE
        WHEN p_expire_after IS NULL THEN NULL
        ELSE now() + p_expire_after
    END;

    INSERT INTO knowledge.known_players_squad_profiles
        (player_id, squad_id, updated_at, expires_at)
    VALUES
        (p_player_id, p_other_squad_id, now(), v_expires_at)
    ON CONFLICT (player_id, other_player_id) DO UPDATE
        SET updated_at = now(),
	        expires_at = CASE
	            WHEN p_expire_after IS NULL          THEN NULL
	            WHEN expires_at IS NULL              THEN NULL
	            ELSE GREATEST(expires_at, v_expires_at)
	            END;

END;
$function$
;
