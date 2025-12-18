CREATE OR REPLACE FUNCTION inventory.check_inventory_container_exists(p_inventory_container_id int)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.inventory_containers WHERE id = p_inventory_container_id) THEN
        PERFORM util.raise_error('P0001', 'Inventory container does not exist');
    END IF;
END;
$$;