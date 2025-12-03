    
CREATE OR REPLACE FUNCTION inventory.create_inventory_container(
    p_owner_type TEXT,      -- 'player', 'building', 'district'
    p_owner_id INT,         -- ID właściciela
    p_inventory_size INT DEFAULT 5  -- liczba slotów 
)
RETURNS TABLE(status TEXT, message TEXT, container_id INT)
LANGUAGE plpgsql
AS $$
DECLARE
	container_id INT;
BEGIN

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
    ELSE
        RETURN QUERY SELECT 'fail', 'Invalid owner type', NULL;
        RETURN;
    END IF;




	FOR x IN 1..p_inventory_size LOOP
	        INSERT INTO inventory.inventory_slots (inventory_container_id)
	        VALUES (container_id);
	    END LOOP;



    RETURN QUERY SELECT 'ok', 'Container created successfully', container_id;
END;
$$;
