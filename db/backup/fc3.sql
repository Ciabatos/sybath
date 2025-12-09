CREATE OR REPLACE FUNCTION world.player_movement(p_player_id integer, p_path jsonb)
 RETURNS TABLE(status text, message text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    tile jsonb;
BEGIN
    PERFORM tasks.cancel_task(p_player_id, 'world.player_movement');

    FOR tile IN 
		SELECT * FROM jsonb_array_elements(p_path)
    LOOP
        PERFORM tasks.insert_task(p_player_id, 'world.player_movement', tile);
    END LOOP;

    RETURN QUERY SELECT 'ok', 'Movement actions assigned';
END;
$function$
;
