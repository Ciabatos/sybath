CREATE OR REPLACE FUNCTION items.check_quantity_positive(p_quantity int)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_quantity <= 0 THEN
        PERFORM util.raise_error('P0002', 'Quantity must be greater than 0');
    END IF;
END;
$$;