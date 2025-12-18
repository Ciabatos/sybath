CREATE OR REPLACE FUNCTION inventory.do_add_item_to_inventory(p_inventory_container_id integer, p_item_id integer, p_quantity integer)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
AS $function$
BEGIN

PERFORM items.check_item_exists(p_item_id);
PERFORM items.check_quantity_positive(p_quantity);
PERFORM inventory.check_inventory_container_exists(p_inventory_container_id);
PERFORM inventory.check_free_inventory_slots(p_inventory_container_id);


PERFORM inventory.add_item_to_inventory_free_slot(p_inventory_container_id, p_item_id, p_quantity);

        
        
    RETURN QUERY SELECT 'ok', 'Item added successfully';
    
	EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT 'fail', SQLERRM;
            ELSE
                RETURN QUERY SELECT 'fail', 'Operation failed';
            END IF;
    END;

END;
$function$
;

COMMENT ON FUNCTION inventory.do_add_item_to_inventory(int4, int4, int4) IS 'action_api';
