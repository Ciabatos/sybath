-- DROP FUNCTION players.other_player_profile_knowledge_request(int4, text);

CREATE OR REPLACE FUNCTION players.other_player_knowledge_request(p_player_id integer, p_other_player_id text, p_knowledge_type_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_other_player_id integer;
BEGIN

    v_other_player_id := players.get_real_player_id(p_other_player_id);

    -- nie można zaprosić samego siebie
    IF p_player_id = v_other_player_id THEN
        PERFORM util.raise_error('Cannot invite yourself');
    END IF;

    -- brak duplikatu (pending)
    IF EXISTS (
        SELECT 1
        FROM players.other_player_knowledge_requests
        WHERE inviter_player_id = p_player_id
          AND invited_player_id = v_other_player_id
		  AND knowledge_type_id = p_knowledge_type_id
          AND status in ( 1,3 )
    ) THEN
        PERFORM util.raise_error('Invite already exists');
    END IF;

    INSERT INTO players.other_player_knowledge_requests
    (inviter_player_id, invited_player_id, knowledge_type_id, status, created_at, responded_at)
    VALUES(p_player_id, v_other_player_id, p_knowledge_type_id, 1, now(), NULL);

END;
$function$
;
