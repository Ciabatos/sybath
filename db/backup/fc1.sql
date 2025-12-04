-- DROP FUNCTION inventory.add_item_to_inventory(int4, int4, int4);

CREATE OR REPLACE FUNCTION inventory.add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    updated_row RECORD;
BEGIN
 SELECT T2.id
    INTO updated_row
    FROM inventory.inventory_containers t1
    JOIN inventory.inventory_slots t2 ON t1.id  = t2.inventory_container_id 
    WHERE T1.id  = p_inventory_container_id 
      AND T2.item_id IS NULL
    ORDER BY T2.id ASC
    LIMIT 1;


 IF updated_row IS NULL THEN

        RETURN QUERY SELECT 'fail', 'No free slot in inventory';

 ELSE

        UPDATE inventory.inventory_slots t1
          SET item_id = p_item_id,
              quantity = COALESCE(t1.quantity, 0) + p_quantity
        WHERE t1.inventory_container_id = p_inventory_container_id
          AND t1.id = updated_row.id;

        RETURN QUERY SELECT 'ok', 'Item added successfully';

 END IF;

END;
$function$
;
