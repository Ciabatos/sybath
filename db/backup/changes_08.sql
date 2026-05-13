CREATE OR REPLACE FUNCTION players.do_spy_on_other_player(p_player_id integer, p_other_player_id text, p_knowledge_type_id integer)
 RETURNS TABLE(status boolean, message text)
 LANGUAGE plpgsql
AS $function$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM players.spy_on_other_player(p_player_id, p_other_player_id, p_knowledge_type_id);

    RETURN QUERY SELECT true, 'Spying action completed';

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

COMMENT ON FUNCTION players.do_spy_on_other_player(int4, text, int) IS 'action_api';
