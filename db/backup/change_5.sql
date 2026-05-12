
CREATE OR REPLACE FUNCTION players.do_other_player_knowledge_request(p_player_id integer, p_other_player_id text, p_knowledge_type_id integer)
 RETURNS TABLE(status boolean, message text)
 LANGUAGE plpgsql
AS $function$
BEGIN

    /* MUTEX */
    PERFORM 1
    FROM players.players
    WHERE id = p_player_id
    FOR UPDATE;

PERFORM players.other_player_knowledge_request(p_player_id,p_other_player_id, p_knowledge_type_id);

    RETURN QUERY SELECT true, 'Invited to cognize';

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

COMMENT ON FUNCTION players.do_other_player_knowledge_request(int4, text, int4) IS 'action_api';
