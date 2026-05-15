CREATE OR REPLACE FUNCTION players.spy_on_other_player(p_player_id integer, p_other_player_id text, p_knowledge_type_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_other_player_id integer;
	v_spy_level integer;
	v_expire_after interval;
BEGIN

    v_other_player_id := players.get_real_player_id(p_other_player_id);

	IF v_other_player_id IS NULL THEN
	    RETURN;
	END IF;

	v_spy_level := 1;

    -- nie można samego siebie
    IF p_player_id = v_other_player_id THEN
        PERFORM util.raise_error('Cannot spy on yourself');
    END IF;

    IF p_knowledge_type_id = 1 THEN
	    PERFORM players.discover_other_player_profile(p_player_id, v_other_player_id);
    END IF;

    IF p_knowledge_type_id = 2 THEN
	    PERFORM players.discover_other_player_skills(p_player_id, v_other_player_id);
    END IF;

    IF p_knowledge_type_id = 3 THEN
	    PERFORM players.discover_other_player_abilities(p_player_id, v_other_player_id);
    END IF;

    IF p_knowledge_type_id = 4 THEN
	    PERFORM players.discover_other_player_stats(p_player_id, v_other_player_id);
    END IF;

    IF p_knowledge_type_id = 5 THEN
		PERFORM inventory.discover_container(p_player_id, inventory.player_inventory_container(v_other_player_id));
    END IF;

    IF p_knowledge_type_id = 6 THEN
    	v_expire_after := v_spy_level * interval '1 hour';
	    PERFORM players.discover_other_player_positions(p_player_id, v_other_player_id, v_expire_after);
    END IF;

END;
$function$
;
