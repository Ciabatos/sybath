CREATE SCHEMA trade AUTHORIZATION postgres;

CREATE TABLE trade.trades (
    id SERIAL PRIMARY KEY,
	status int4 DEFAULT 1 NOT NULL,
    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp,
    expires_at timestamp
);



CREATE TABLE trade.trade_participants (
    trade_id int NOT NULL,
    entity_id int NOT NULL,
    entity_type int NOT NULL,
    side int NOT NULL,
    accepted boolean NOT NULL DEFAULT false,

    PRIMARY KEY (trade_id, entity_type, entity_id),
    FOREIGN KEY (trade_id)
        REFERENCES trade.trades(id) ON DELETE CASCADE
);


CREATE TABLE trade.trade_slots (
    id SERIAL PRIMARY KEY,
    trade_id int NOT NULL,
    from_entity_id int NOT NULL,
    from_entity_type int NOT NULL,
    item_id int,
    quantity int,
    created_at timestamp NOT NULL DEFAULT now(),

    FOREIGN KEY (trade_id)
        REFERENCES trade.trades(id) ON DELETE CASCADE
);



CREATE OR REPLACE FUNCTION trade.trade_open(p_player_id integer, p_inviter_entity_id integer, p_inviter_entity_type integer, p_invited_entity_id integer, p_invited_entity_type integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_trade_id int;
BEGIN

    IF p_inviter_entity_id = p_invited_entity_id
    AND p_inviter_entity_type = p_invited_entity_type THEN
        PERFORM util.raise_error('Cannot trade with yourself');
    END IF;

    IF EXISTS (
        SELECT 1
		FROM trade.trade_participants TP1
		JOIN trade.trade_participants TP2 ON TP1.trade_id = TP2.trade_id
										  AND TP2.entity_id = p_invited_entity_id
									      AND TP2.entity_type = p_invited_entity_type
        JOIN trade.trades T ON T.id = TP1.trade_id
		WHERE TP1.entity_id = p_inviter_entity_id
		AND TP1.entity_type = p_inviter_entity_type
	    AND T.status IN (0, 1, 2)
    ) THEN
        PERFORM util.raise_error('Invite already exists');
    END IF;


		INSERT INTO trade.trades
		(status, created_at, updated_at, expires_at)
		VALUES(1, now(), NULL, NULL)   
	    RETURNING id INTO v_trade_id;
		
		INSERT INTO trade.trade_participants
		(trade_id, entity_id, entity_type, side, accepted)
		VALUES(v_trade_id, p_inviter_entity_id, p_inviter_entity_type, 1, false);

		INSERT INTO trade.trade_participants
		(trade_id, entity_id, entity_type, side, accepted)
		VALUES(v_trade_id, p_invited_entity_id, p_invited_entity_type, 2, false);

		INSERT INTO trade.trade_slots
		(trade_id, from_entity_id, from_entity_type, item_id, quantity, created_at)
		SELECT
		    v_trade_id,
		    p_inviter_entity_id,
		    p_inviter_entity_type,
		    NULL,
		    NULL,
			now()
		FROM generate_series(1, 12) gs;
		
		INSERT INTO trade.trade_slots
		(trade_id, from_entity_id, from_entity_type, item_id, quantity, created_at)
		SELECT
		    v_trade_id,
		    p_invited_entity_id,
		    p_invited_entity_type,
		    NULL,
		    NULL,
			now()
		FROM generate_series(1, 12) gs;

END;
$function$
;



INSERT INTO inventory.inventory_container_types
("name")
VALUES('Trade');



CREATE OR REPLACE FUNCTION trade.get_trade_inventory(p_player_id integer, p_entity_id integer, p_entity_type integer, p_trade_id integer)
 RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer, side integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT t3.id AS slot_id,
           t1.id AS container_id,
           5 AS inventory_container_type_id, --TRADE
           1 AS inventory_slot_type_id, -- ANY
           t3.item_id,
           t4.name,
           t3.quantity,
		   t2.side
    FROM trade.trades t1  
	JOIN trade.trade_participants T2 ON T2.trade_id = t1.id
								     AND t2.entity_id = p_entity_id
								     AND t2.entity_type = p_entity_type
    JOIN trade.trade_slots t3 ON t3.trade_id = t2.trade_id
    LEFT JOIN items.items T4 ON T3.item_id = T4.id
    WHERE t1.id = p_trade_id
    ORDER BY t3.id ASC;
END;
$function$
;

COMMENT ON FUNCTION trade.get_trade_inventory(int4, int4, int4, int4) IS 'get_api';




get_dostepne_entity_inventories_on_tile - lista graczy/budynkow z ekwipunkiem na tym tile gdzie jest dokonywany trade 
po kliknieciu na to otwiera sie dany inventory