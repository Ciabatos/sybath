-- DROP FUNCTION inventory.add_inventory_container(text, int4, int4);

CREATE OR REPLACE FUNCTION inventory.add_inventory_container(p_owner_type text, p_owner_id integer, p_inventory_size integer DEFAULT 5)
 RETURNS TABLE(status text, message text, container_id integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    container_id INT;
BEGIN


IF      p_owner_type != 'player' 
	AND p_owner_type != 'building' 
	AND p_owner_type != 'district'  THEN
		RETURN QUERY SELECT 'fail', 'Invalid owner type', NULL;
		RETURN;
END IF;



    INSERT INTO inventory.inventory_containers (inventory_size)
    VALUES (p_inventory_size)
    RETURNING id INTO container_id;


    IF p_owner_type = 'player' THEN
        INSERT INTO inventory.inventory_container_player (container_id, player_id)
        VALUES (container_id, p_owner_id);
    ELSIF p_owner_type = 'building' THEN
        INSERT INTO inventory.inventory_container_building (container_id, building_id)
        VALUES (container_id, p_owner_id);
    ELSIF p_owner_type = 'district' THEN
        INSERT INTO inventory.inventory_container_district (container_id, district_id)
        VALUES (container_id, p_owner_id);
    END IF;




    FOR x IN 1..p_inventory_size LOOP
            INSERT INTO inventory.inventory_slots (inventory_container_id)
            VALUES (container_id);
        END LOOP;
    RETURN QUERY SELECT 'ok', 'Container created successfully', container_id;


END;
$function$
;
