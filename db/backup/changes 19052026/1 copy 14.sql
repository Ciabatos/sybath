 DROP FUNCTION players.other_player_knowledge_accept(int4, int4);

CREATE OR REPLACE FUNCTION knowledge.other_player_knowledge_accept(p_player_id integer, p_invite_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_inviter_player_id integer;
    v_knowledge_type_id integer;
BEGIN


    SELECT inviter_player_id, knowledge_type_id INTO v_inviter_player_id, v_knowledge_type_id
    FROM knowledge.knowledge_requests
    WHERE id = p_invite_id
    AND invited_player_id = p_player_id
    AND status in (1)
    LIMIT 1;

    IF v_inviter_player_id IS NULL THEN
        PERFORM util.raise_error('Player not invited');
    END IF;

    IF v_knowledge_type_id = 1 THEN
        PERFORM knowledge.discover_other_player_profile(p_player_id, v_inviter_player_id);
        PERFORM knowledge.discover_other_player_profile(v_inviter_player_id, p_player_id);
    END IF;

    IF v_knowledge_type_id = 2 THEN
        PERFORM knowledge.discover_other_player_skills(p_player_id, v_inviter_player_id);
        PERFORM knowledge.discover_other_player_skills(v_inviter_player_id, p_player_id);
    END IF;

    IF v_knowledge_type_id = 3 THEN
        PERFORM knowledge.discover_other_player_abilities(p_player_id, v_inviter_player_id);
        PERFORM knowledge.discover_other_player_abilities(v_inviter_player_id, p_player_id);
    END IF;

    IF v_knowledge_type_id = 4 THEN
        PERFORM knowledge.discover_other_player_stats(p_player_id, v_inviter_player_id);
        PERFORM knowledge.discover_other_player_stats(v_inviter_player_id, p_player_id);
    END IF;

    IF v_knowledge_type_id = 5 THEN
        PERFORM knowledge.discover_container(p_player_id, inventory.player_inventory_container(v_inviter_player_id));
        PERFORM knowledge.discover_container(v_inviter_player_id, inventory.player_inventory_container(p_player_id));
    END IF;

    IF v_knowledge_type_id = 6 THEN
        PERFORM knowledge.discover_other_player_positions(p_player_id, v_inviter_player_id, NULL);
        PERFORM knowledge.discover_other_player_positions(v_inviter_player_id, p_player_id, NULL);
    END IF;

    UPDATE knowledge.knowledge_requests
    SET status = 3, responded_at = now()
    WHERE id = p_invite_id;

END;
$function$
;
