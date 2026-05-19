ALTER TABLE inventory.inventory_containers ADD CONSTRAINT inventory_containers_players_fk FOREIGN KEY (owner_id) REFERENCES players.players(id);
