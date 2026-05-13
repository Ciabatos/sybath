ALTER TABLE knowledge.known_players_abilities
ADD COLUMN snapshot jsonb,
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;

ALTER TABLE knowledge.known_players_containers
ADD COLUMN snapshot jsonb,
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;

ALTER TABLE knowledge.known_players_positions
ADD COLUMN snapshot jsonb,
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;

ALTER TABLE knowledge.known_players_skills
ADD COLUMN snapshot jsonb,
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;

ALTER TABLE knowledge.known_players_squad_profiles
ADD COLUMN snapshot jsonb,
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;

ALTER TABLE knowledge.known_players_stats
ADD COLUMN snapshot jsonb,
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;