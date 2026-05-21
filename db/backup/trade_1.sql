CREATE SCHEMA trade AUTHORIZATION postgres;


CREATE TABLE trade.trades (
	id serial4 NOT NULL,
	status int4 DEFAULT 1 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp NULL,
	expires_at timestamp NULL,
	CONSTRAINT trades_pkey PRIMARY KEY (id),
	CONSTRAINT trades_request_statuses_fk FOREIGN KEY (status) REFERENCES util.request_statuses(id)
);

CREATE TABLE trade.trade_participants (
	trade_id int4 NOT NULL,
	player_id int4 NOT NULL,
	side int4 NOT NULL,
	accepted bool DEFAULT false NOT NULL,
	CONSTRAINT trade_participants_pkey PRIMARY KEY (trade_id, player_id),
	CONSTRAINT trade_participants_trade_id_fkey FOREIGN KEY (trade_id) REFERENCES trade.trades(id) ON DELETE CASCADE
);

CREATE TABLE trade.trade_slots (
	id serial4 NOT NULL,
	trade_id int4 NOT NULL,
	player_id int4 NOT NULL,
	from_entity_id int4 NULL,
	from_entity_type int4 NULL,
	item_id int4 NULL,
	quantity int4 NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	CONSTRAINT trade_slots_pkey PRIMARY KEY (id),
	CONSTRAINT trade_slots_participant_fk FOREIGN KEY (trade_id,player_id) REFERENCES trade.trade_participants(trade_id,player_id) ON DELETE CASCADE
);

INSERT INTO inventory.inventory_container_types
("name")
VALUES('Trade');


-- DROP FUNCTION trade.trade_open(int4, int4, int4, int4, int4);

CREATE OR REPLACE FUNCTION trade.trade_open(p_player_id integer, p_invited_player_id integer)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_trade_id int;
BEGIN
    IF p_player_id = p_invited_player_id THEN
        PERFORM util.raise_error('Cannot trade with yourself');
    END IF;

    IF EXISTS (
        SELECT 1
        FROM trade.trade_participants tp1
        JOIN trade.trade_participants tp2 ON tp2.trade_id = tp1.trade_id
                                         AND tp2.player_id = p_invited_player_id
        JOIN trade.trades t              ON t.id = tp1.trade_id
        WHERE tp1.player_id = p_player_id
          AND t.status IN (1, 2)
    ) THEN
        PERFORM util.raise_error('Active trade already exists between these players');
    END IF;

    INSERT INTO trade.trades (status, created_at)
    VALUES (1, now())
    RETURNING id INTO v_trade_id;

    INSERT INTO trade.trade_participants (trade_id, player_id, side, accepted)
    VALUES
        (v_trade_id, p_player_id,         1, false),
        (v_trade_id, p_invited_player_id, 2, false);

    INSERT INTO trade.trade_slots (trade_id, player_id, item_id, quantity, created_at)
    SELECT v_trade_id, p_player_id, NULL, NULL, now()
    FROM generate_series(1, 12);

    INSERT INTO trade.trade_slots (trade_id, player_id, item_id, quantity, created_at)
    SELECT v_trade_id, p_invited_player_id, NULL, NULL, now()
    FROM generate_series(1, 12);
END;
$function$
;




CREATE OR REPLACE FUNCTION trade.get_trade_inventory(p_player_id integer, p_trade_id integer)
 RETURNS TABLE(slot_id integer, container_id integer, inventory_container_type_id integer, inventory_slot_type_id integer, item_id integer, name character varying, quantity integer, side integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
    RETURN QUERY
    SELECT ts.id AS slot_id,
           t.id AS container_id,
           5 AS inventory_container_type_id, --TRADE
           1 AS inventory_slot_type_id, -- ANY
           ts.item_id,
           i.name,
           ts.quantity,
		   tp.side
    FROM trade.trades t
    JOIN trade.trade_participants tp ON tp.trade_id = t.id
    JOIN trade.trade_slots ts        ON ts.trade_id = t.id
                                    AND ts.player_id = tp.player_id
    LEFT JOIN items.items i          ON i.id = ts.item_id
    WHERE t.id = p_trade_id
    ORDER BY tp.side, ts.id;

END;
$function$
;

COMMENT ON FUNCTION trade.get_trade_inventory(int4, int4) IS 'get_api';





get_dostepne_entity_inventories_on_tile - lista graczy/budynkow z ekwipunkiem na tym tile gdzie jest dokonywany trade
proponowany tile do handlu ?
po kliknieciu otwieraja sie wszystkie inventory jakie gracz ma - na to otwiera sie dany inventory
moze jak jest z innych tiles to automatyczna propozycja dla logistic hub do transportu ?