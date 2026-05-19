DROP FUNCTION players.discover_other_player_abilities(int4, text);

CREATE OR REPLACE FUNCTION knowledge.discover_other_player_abilities(p_player_id integer, p_other_player_id text)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_other_player_id integer;
    v_snapshot jsonb;
BEGIN

    v_other_player_id := players.get_real_player_id(p_other_player_id);

    -- nieznany gracz
    IF v_other_player_id IS NULL THEN
        RETURN;
    END IF;

    -- nie można odkrywać siebie
    IF p_player_id = v_other_player_id THEN
        RETURN;
    END IF;

    /*
     * Snapshot
     */
    SELECT jsonb_agg(row_to_json(t))
    INTO v_snapshot
    FROM attributes.get_player_abilities(v_other_player_id) t;

    INSERT INTO knowledge.known_players_abilities
    (
        player_id,
        other_player_id,
        updated_at,
        snapshot
    )
    VALUES
    (
        p_player_id,
        v_other_player_id,
        now(),
        v_snapshot
    )
    ON CONFLICT (player_id, other_player_id)
    DO UPDATE
    SET
        updated_at = now(),
        snapshot = CASE
            WHEN snapshot IS NULL THEN NULL
            ELSE v_snapshot
        END;

END;
$function$
;
