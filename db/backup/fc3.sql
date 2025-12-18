CREATE OR REPLACE FUNCTION utils.raise_error(p_message text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        USING
            ERRCODE = 'P0001',
            MESSAGE = p_message;
END;
$$;
