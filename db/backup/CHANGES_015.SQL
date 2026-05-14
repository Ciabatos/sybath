
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

	SELECT inventory_container_type_id
	INTO v_inventory_container_type_id
	FROM inventory.inventory_containers
	WHERE id = p_container_id;

    /*
     * Snapshot
     */

TUTAJ DODAC FUNKCJE DLA KAZDEGO CONTENERA
	IF v_inventory_container_type_id = 1 THEN
	    SELECT jsonb_agg(row_to_json(t))
	    INTO v_snapshot
	    FROM attributes.get_player_abilities(v_other_player_id) t;
	IF v_inventory_container_type_id = 2 THEN
	    SELECT jsonb_agg(row_to_json(t))
	    INTO v_snapshot
	    FROM attributes.get_player_abilities(v_other_player_id) t;
	IF v_inventory_container_type_id = 3 THEN
	    SELECT jsonb_agg(row_to_json(t))
	    INTO v_snapshot
	    FROM attributes.get_player_abilities(v_other_player_id) t;
	IF v_inventory_container_type_id = 4 THEN
	    SELECT jsonb_agg(row_to_json(t))
	    INTO v_snapshot
	    FROM attributes.get_player_abilities(v_other_player_id) t;
	ELSE RETURN;

    INSERT INTO knowledge.known_players_containers
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
    	    WHEN snapshot IS NULL THEN NULL
    	    ELSE v_snapshot
	    END;

END;
$function$
;