CREATE OR REPLACE FUNCTION tasks.insert_task(p_player_id integer, p_method_name character varying, p_parameters json)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE

BEGIN


INSERT
    INTO
    tasks.tasks (
            player_id,
            status,
            created_at,
            scheduled_at,
            last_executed_at,
            "error",
            method_name,
            method_parameters

        )
VALUES (
            p_player_id,
            1,
            NOW(),
            NOW() + INTERVAL '5 minutes',
            NULL,
            NULL,
            p_method_name,
            p_parameters::jsonb

        );

END;

$function$
;