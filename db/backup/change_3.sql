CREATE OR REPLACE FUNCTION players.get_other_player_knowledge_requests(p_player_id integer)
 RETURNS TABLE(id integer, other_player_id text, name character varying, second_name character varying, nickname character varying, image_portrait character varying, knowledge_type_id int, created_at timestamp without time zone)
 LANGUAGE plpgsql
AS $function$
BEGIN

	RETURN QUERY

SELECT      opkr.id
			,CASE WHEN kpp.other_player_id IS NOT NULL THEN kpp.other_player_id::text ELSE p.masked_id::text END AS other_player_id
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.name ELSE NULL END AS name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.second_name ELSE NULL END AS second_name
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.nickname ELSE NULL END AS nickname
            ,CASE WHEN kpp.other_player_id IS NOT NULL THEN p.image_portrait ELSE NULL END AS image_portrait
			,opkr.knowledge_type_id
			,opkr.created_at
	FROM players.other_player_knowledge_requests opkr
	JOIN players.players p ON opkr.inviter_player_id = p.id
	LEFT JOIN knowledge.known_players_profiles kpp ON kpp.player_id = p_player_id
	                                               AND kpp.other_player_id = p.id
	WHERE invited_player_id = p_player_id
	AND status = 1
	ORDER BY opkr.knowledge_type_id ASC;

END;
$function$
;

COMMENT ON FUNCTION players.get_other_player_knowledge_requests(int4) IS 'get_api';
