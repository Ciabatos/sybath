CREATE OR REPLACE FUNCTION trade.check_trade_slot_access(p_entity_id integer, p_entity_type integer, p_slot_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF NOT EXISTS (
SELECT
1
FROM trade.trade_participants tp
JOIN trade.trade_slots ts on tp.trade_id = ts.trade_id 
						  and tp.entity_id = ts.from_entity_id 
						  and tp.entity_type = ts.from_entity_type
WHERE ts.id = p_slot_id
AND tp.entity_id = p_entity_id
AND tp.entity_type = p_entity_type
LIMIT 1
) THEN
        PERFORM util.raise_error('You have no access to trade on this container');
    END IF;
END;
$function$
;