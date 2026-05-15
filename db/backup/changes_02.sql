CREATE OR REPLACE FUNCTION players.discover_other_player_abilities(p_player_id integer, p_other_player_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_snapshot jsonb;
BEGIN

    -- nieznany gracz
    IF p_other_player_id IS NULL THEN
        RETURN;
    END IF;

    -- nie można odkrywać siebie
    IF p_player_id = p_other_player_id THEN
        RETURN;
    END IF;

    /*
     * Snapshot
     */
    SELECT jsonb_agg(row_to_json(t))
    INTO v_snapshot
    FROM attributes.get_player_abilities(p_other_player_id) t;

    INSERT INTO knowledge.known_players_abilities as t1
    (
        player_id,
        other_player_id,
        updated_at,
        snapshot
    )
    VALUES
    (
        p_player_id,
        p_other_player_id,
        now(),
        v_snapshot
    )
    ON CONFLICT (player_id, other_player_id)
    DO UPDATE
    SET
        updated_at = now(),
        snapshot = CASE
    	    WHEN t1.snapshot IS NULL THEN NULL
    	    ELSE v_snapshot
	    END;

END;
$function$;