CREATE OR REPLACE FUNCTION inventory.get_container_inventory (p_container_id integer)
 RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           t1.inventory_container_type_id,
           t3.inventory_slot_type_id,
           t3.item_id,
           t4.name,
           t3.quantity
    FROM inventory.inventory_containers t1  
    JOIN inventory.inventory_slots t3 ON t3.inventory_container_id = t1.id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.id = p_container_id
    ORDER BY t3.id ASC;
END;
$function$
;