
CREATE OR REPLACE FUNCTION squad.discover_squad_profiles(p_player_id integer, p_other_squad_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_snapshot jsonb;
BEGIN

    -- nieznany gracz
    IF p_other_squad_id IS NULL THEN
        RETURN;
    END IF;

    /*
     * Snapshot
     */
    SELECT jsonb_agg(row_to_json(t))
    INTO v_snapshot
    FROM squad.get_active_player_squad_players_profiles(p_other_squad_id) t;

    INSERT INTO knowledge.known_players_squad_profiles as t1
    (
        player_id,
        squad_id,
        updated_at,
        snapshot
    )
    VALUES
    (
        p_player_id,
        p_other_squad_id,
        now(),
        v_snapshot
    )
    ON CONFLICT (player_id, squad_id)
    DO UPDATE
    SET
        updated_at = now(),
        snapshot = CASE
    	    WHEN t1.snapshot IS NULL THEN NULL
    	    ELSE v_snapshot
	    END;

END;
$function$;
