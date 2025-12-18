CREATE OR REPLACE FUNCTION utils.raise_error(p_message text, VARIADIC p_args text[])
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    msg text;
BEGIN
    -- jeśli nie podano argumentów, używa samego tekstu
    -- przykład użycia PERFORM utils.raise_error('Cannot add % units of item %', p_quantity::text, p_item_id::text);
    msg := format(p_message, VARIADIC p_args);

    RAISE EXCEPTION
        USING ERRCODE = 'P0001',
              MESSAGE = msg;
END;
$$;