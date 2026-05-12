CREATE TABLE
	knowledge.knowledge_types (
		id serial4 PRIMARY KEY,
		code varchar(50) NOT NULL UNIQUE,
		description varchar(255)
	);

INSERT INTO
	knowledge.knowledge_types (code, description)
VALUES
	('other_player_profile', 'Player profile access'),
	('other_player_skills', 'Player skills access'),
	(
		'other_player_abilities',
		'Player abilities access'
	),
	('other_player_stats', 'Player stats access'),
	('containers', 'Player containers access'),
	(
		'other_player_positions',
		'Player positions access'
	),
	('map_tiles', 'Known map tiles access'),
	(
		'map_tiles_resources',
		'Known map resources access'
	),
	('squad_profiles', 'Squad profile access');

CREATE TABLE
	players.other_player_knowledge_requests (
		id serial4 NOT NULL,
		inviter_player_id int4 NOT NULL,
		invited_player_id int4 NOT NULL,
		knowledge_type_id int4 NOT NULL,
		status int4 DEFAULT 1 NOT NULL,
		created_at timestamp DEFAULT now () NOT NULL,
		responded_at timestamp NULL,
		CONSTRAINT other_player_knowledge_requests_pkey PRIMARY KEY (id),
		CONSTRAINT other_player_knowledge_requests_unique UNIQUE (inviter_player_id, invited_player_id, status),
		CONSTRAINT other_player_knowledge_requests_knowledge_types_fk FOREIGN KEY (knowledge_type_id) REFERENCES knowledge.knowledge_types (id),
		CONSTRAINT other_player_knowledge_requests_players_fk FOREIGN KEY (inviter_player_id) REFERENCES players.players (id),
		CONSTRAINT other_player_knowledge_requests_players_fk_1 FOREIGN KEY (invited_player_id) REFERENCES players.players (id),
		CONSTRAINT other_player_knowledge_requests_request_statuses_fk FOREIGN KEY (status) REFERENCES util.request_statuses (id)
	);