CREATE OR REPLACE FUNCTION items.check_item_exists(p_item_id int)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM inventory.items WHERE id = p_item_id) THEN
        PERFORM util.raise_error('P0001', 'Item does not exist');
    END IF;
END;
$$;