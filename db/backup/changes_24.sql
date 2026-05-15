CREATE OR REPLACE FUNCTION players.other_player_knowledge_decline(p_player_id integer, p_invite_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
BEGIN

    UPDATE players.other_player_knowledge_requests
    SET status = 4, responded_at = now()
    WHERE id = p_invite_id
	AND invited_player_id = p_player_id;

END;
$function$
;
