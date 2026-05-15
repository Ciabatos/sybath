
CREATE OR REPLACE FUNCTION inventory.discover_container(p_player_id integer, p_container_id integer )
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_inventory_container_type_id int;
    v_snapshot jsonb;
BEGIN

    -- nieznany gracz
    IF p_container_id IS NULL THEN
        RETURN;
    END IF;

    /*
     * Snapshot
     */

	SELECT jsonb_agg(row_to_json(t))
	INTO v_snapshot
	FROM inventory.get_container_inventory(p_container_id) t;
	

    INSERT INTO knowledge.known_players_containers as t1
    (
        player_id,
        container_id,
        updated_at,
        snapshot
    )
    VALUES
    (
        p_player_id,
        p_container_id,
        now(),
        v_snapshot
    )
    ON CONFLICT (player_id, container_id)
    DO UPDATE
    SET
        updated_at = now(),
        snapshot = CASE
    	    WHEN t1.snapshot IS NULL THEN NULL
    	    ELSE v_snapshot
	    END;

END;
$function$
;