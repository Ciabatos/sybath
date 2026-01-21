DROP FUNCTION players.do_switch_active_player(int4, int4);



CREATE OR REPLACE FUNCTION players.do_switch_active_player(p_player_id integer, p_switch_to_player_id integer)
 RETURNS TABLE(status boolean, message text)
 LANGUAGE plpgsql
AS $function$
BEGIN

PERFORM players.switch_active_player(p_player_id, p_switch_to_player_id);

    RETURN QUERY SELECT true, 'Player switched';
    
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLSTATE = 'P0001' THEN
                RETURN QUERY SELECT false, SQLERRM;
            ELSE
                RAISE;
            END IF;

END;
$function$
;



COMMENT ON FUNCTION players.do_switch_active_player(int4, int4) IS 'action_api';
