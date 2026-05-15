-- DROP FUNCTION inventory.get_player_gear_inventory(int4);

CREATE OR REPLACE FUNCTION inventory.get_player_gear_inventory(p_player_id integer)
 RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
BEGIN
    RETURN QUERY
    SELECT *
    FROM inventory.get_container_inventory(
        (
            SELECT c.id
            FROM inventory.inventory_containers c
            WHERE c.owner_id = p_player_id
              AND c.inventory_container_type_id = 2
            LIMIT 1
        )
    );
END;
END;
$function$
;

COMMENT ON FUNCTION inventory.get_player_gear_inventory(int4) IS 'get_api';
