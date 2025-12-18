CREATE OR REPLACE FUNCTION utils.raise_error(p_code text, p_message text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION
        USING
            ERRCODE = p_code,
            MESSAGE = p_message;
END;
$$;
