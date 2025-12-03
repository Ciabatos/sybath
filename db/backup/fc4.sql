

CREATE OR REPLACE FUNCTION inventory.get_player_inventory(p_player_id integer)
RETURNS TABLE(
    slot_id integer,
    container_id integer,
    item_id integer,
    name character varying,
    quantity integer
)
LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t2.id AS container_id,
           t3.item_id,
		   t4.name,
           t3.quantity
    FROM inventory.inventory_container_player t1
    JOIN inventory.inventory_containers t2  ON t1.inventory_container_id = t2.id
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t2.id
	LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.player_id = p_player_id
    ORDER BY t3.id ASC;
END;
$function$;
