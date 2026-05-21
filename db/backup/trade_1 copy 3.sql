CREATE OR REPLACE FUNCTION trade.move_or_swap_item(p_player_id integer, p_from_slot_id integer, p_to_slot_id integer, p_from_inventory_container_id integer, p_to_inventory_container_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_from_item_id   integer;
    v_from_quantity  integer;

    v_to_item_id     integer;
    v_to_quantity    integer;
BEGIN
	PERFORM inventory.check_inventory_slot_exists(p_from_inventory_container_id, p_from_slot_id);
	PERFORM inventory.check_inventory_container_access(p_player_id, p_from_inventory_container_id);
    PERFORM trade.check_trade_slot_access(p_player_id, p_to_slot_id);

    -- Pobierz slot źródłowy (z blokadą)
    SELECT item_id, quantity
    INTO v_from_item_id, v_from_quantity
    FROM inventory.inventory_slots
    WHERE id = p_from_slot_id
      AND inventory_container_id = p_from_inventory_container_id
    FOR UPDATE;

    IF v_from_item_id IS NULL THEN
        PERFORM util.raise_error('Source slot is empty');
    END IF;

    -- Pobierz slot docelowy (z blokadą)
    SELECT item_id, quantity
    INTO v_to_item_id, v_to_quantity
    FROM trade.trade_slots
    WHERE id = p_to_slot_id
      AND trade_id = p_to_inventory_container_id
    FOR UPDATE;


        UPDATE trade.trade_slots
        SET item_id = v_from_item_id,
            quantity = v_from_quantity
        WHERE id = p_to_slot_id;

END;
$function$
;