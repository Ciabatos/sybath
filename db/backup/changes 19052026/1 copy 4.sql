DROP FUNCTION players.discover_other_player_positions(int4, int4, interval);

CREATE OR REPLACE FUNCTION knowledge.discover_other_player_positions(p_player_id integer, p_other_player_id integer, p_expire_after interval DEFAULT NULL::interval)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_expires_at timestamp;
BEGIN
    -- nieznany gracz → cicha rezygnacja
    IF p_other_player_id IS NULL THEN
        RETURN;
    END IF;

    -- gracz nie może "odkryć" samego siebie
    IF p_player_id = p_other_player_id THEN
        RETURN;
    END IF;

    v_expires_at := CASE
        WHEN p_expire_after IS NULL THEN NULL
        ELSE now() + p_expire_after
    END;

    INSERT INTO knowledge.known_players_positions as t1
        (player_id, other_player_id, updated_at, expires_at)
    VALUES
        (p_player_id, p_other_player_id, now(), v_expires_at)
    ON CONFLICT (player_id, other_player_id) DO UPDATE
        SET updated_at = now(),
            expires_at = CASE
                WHEN p_expire_after IS NULL          THEN NULL
                WHEN t1.expires_at IS NULL              THEN NULL
                ELSE GREATEST(t1.expires_at, v_expires_at)
                END;

END;
$function$
;
