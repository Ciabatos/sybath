

 DROP TABLE players.other_player_knowledge_requests;

CREATE TABLE knowledge.knowledge_requests (
	id serial4 NOT NULL,
	inviter_player_id int4 NOT NULL,
	invited_player_id int4 NOT NULL,
	knowledge_type_id int4 NOT NULL,
	status int4 DEFAULT 1 NOT NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	responded_at timestamp NULL,
	CONSTRAINT knowledge_requests_pkey PRIMARY KEY (id),
	CONSTRAINT knowledge_requests_unique UNIQUE (inviter_player_id, invited_player_id, status),
	CONSTRAINT knowledge_requests_knowledge_types_fk FOREIGN KEY (knowledge_type_id) REFERENCES knowledge.knowledge_types(id),
	CONSTRAINT knowledge_requests_players_fk FOREIGN KEY (inviter_player_id) REFERENCES players.players(id),
	CONSTRAINT knowledge_requests_players_fk_1 FOREIGN KEY (invited_player_id) REFERENCES players.players(id),
	CONSTRAINT knowledge_requests_request_statuses_fk FOREIGN KEY (status) REFERENCES util.request_statuses(id)
);