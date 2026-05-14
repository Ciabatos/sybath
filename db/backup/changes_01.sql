ALTER TABLE knowledge.known_players_positions
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN expires_at timestamp;

ALTER TABLE knowledge.known_players_abilities
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN snapshot jsonb,
ALTER TABLE knowledge.known_players_containers
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN snapshot jsonb,
ALTER TABLE knowledge.known_players_skills
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN snapshot jsonb,
ALTER TABLE knowledge.known_players_squad_profiles
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN snapshot jsonb,
ALTER TABLE knowledge.known_players_stats
ADD COLUMN updated_at timestamp NOT NULL DEFAULT now (),
ADD COLUMN snapshot jsonb,