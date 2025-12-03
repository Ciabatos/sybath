
CREATE OR REPLACE FUNCTION inventory.add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer)
 RETURNS TABLE(status text, message text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    updated_row RECORD;
BEGIN
 SELECT T2.x , T2.y, T2.inventory_container_id
    INTO updated_row
    FROM inventory.inventory_containers t1
    JOIN inventory.inventory_slots t2 ON t1.id  = t2.inventory_container_id 
    WHERE T1.id  = p_inventory_container_id 
      AND T2.item_id IS NULL
    ORDER BY T2.x ASC, T2.y ASC
    LIMIT 1;

    IF NOT FOUND THEN
        RETURN QUERY SELECT 'fail', 'No free slot in inventory';
        RETURN;
    END IF;

    UPDATE inventory.inventory_slots T1
    SET item_id = p_item_id,
        quantity = COALESCE(T1.quantity, 0) + p_quantity
    WHERE T1.inventory_container_id = updated_row.inventory_container_id
      AND T1.x = updated_row.x
      AND T1.y = updated_row.y;

    RETURN QUERY SELECT 'ok', 'Item added successfully';
END;
$$;