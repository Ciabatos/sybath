ALTER TABLE players.players
ADD COLUMN is_default BOOLEAN DEFAULT FALSE;

update players.players set is_default = true where id = 1

CREATE UNIQUE INDEX one_default_player_per_user
ON players.players(user_id)
WHERE is_default = true;