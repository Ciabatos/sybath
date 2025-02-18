export async function getJoinedMapTiles(terrainById: Record<string, TMapTerrainTypes>) {
  const tiles = await getMapTiles();

  return Object.fromEntries(
    tiles.map(tile => {
      const key = `${tile.x},${tile.y}`;
      const terrain = terrainById[tile.terrain_type_id];
      return [key, {
        ...tile,
        terrain_name: terrain?.name,
        terrain_move_cost: terrain?.terrain_move_cost
      }];
    })
  ) as Record<string, TJoinedMapTile>;
}

export async function getTerrainTypeDictionary() {
  const terrainTypes = await fetchMapTerrainTypes();
  return arrayToObjectKeyId(terrainTypes);
}

// Usage in the component
const terrainTypes = await getTerrainTypeDictionary();
const joinedMapTiles = await getJoinedMapTiles(terrainTypes);
