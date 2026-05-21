CREATE OR REPLACE FUNCTION trade.check_trade_slot_access(
    p_player_id integer,
    p_slot_id   integer
)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM trade.trade_slots
        WHERE id        = p_slot_id
          AND player_id = p_player_id
    ) THEN
        PERFORM util.raise_error('You have no access to trade on this container');
    END IF;
END;
$$;