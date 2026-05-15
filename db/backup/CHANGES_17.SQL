CREATE OR REPLACE FUNCTION inventory.get_other_player_gear_inventory(p_player_id integer,p_other_player_id text)
RETURNS TABLE(slot_id integer,container_id integer,inventory_container_type_id integer,inventory_slot_type_id integer,item_id integer,name character varying,quantity integer)
LANGUAGE plpgsql
AS $function$
DECLARE
    v_container_id int;
    v_snapshot jsonb;
BEGIN

    SELECT
        t1.id,
        kpc.snapshot
    INTO
        v_container_id,
        v_snapshot
    FROM inventory.inventory_containers t1
    LEFT JOIN knowledge.known_players_containers kpc ON kpc.player_id = p_player_id
       												 AND kpc.container_id = t1.id
    WHERE t1.owner_id = players.get_real_player_id(p_other_player_id)
	AND t1.inventory_container_type_id = 2
	LIMIT 1;

    IF v_snapshot IS NULL THEN

        RETURN QUERY
        SELECT *
        FROM inventory.get_container_inventory(v_container_id);

    ELSE

        RETURN QUERY
        SELECT
            x.slot_id,
            x.container_id,
            x.inventory_container_type_id,
            x.inventory_slot_type_id,
            x.item_id,
            x.name,
            x.quantity
        FROM jsonb_to_recordset(v_snapshot) AS x (
            slot_id integer,
            container_id integer,
            inventory_container_type_id integer,
            inventory_slot_type_id integer,
            item_id integer,
            name character varying,
            quantity integer
        );

    END IF;

END;
$function$;