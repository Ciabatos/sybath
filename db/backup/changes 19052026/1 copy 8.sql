DROP FUNCTION players.do_other_player_knowledge_accept(int4, int4);
 
CREATE OR REPLACE FUNCTION knowledge.do_other_player_knowledge_accept(p_player_id integer, p_invite_id integer)
 RETURNS TABLE(status boolean, message text)
 LANGUAGE plpgsql
AS $function$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM knowledge.other_player_knowledge_accept(p_player_id, p_invite_id);

    RETURN QUERY SELECT true, 'Accepted cognize';

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

COMMENT ON FUNCTION knowledge.do_other_player_knowledge_accept(int4, int4) IS 'action_api';
