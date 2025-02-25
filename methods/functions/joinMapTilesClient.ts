import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"

export type TjoinedMapTile = {
  id: number
  x: number
  y: number
  terrain_type_id: number
  terrain_name?: string
  terrain_move_cost?: number
}

export function joinMapTilesClient(oldTiles: Record<string, TjoinedMapTile>, newTiles: TMapTiles[], terrainTypes: Record<number, TMapTerrainTypes>): Record<string, TjoinedMapTile> {
  newTiles.forEach((newTile) => {
    const key = `${newTile.x},${newTile.y}`
    const existingTile = oldTiles[key]

    if (existingTile) {
      existingTile.terrain_type_id = newTile.terrain_type_id

      const terrain = terrainTypes[newTile.terrain_type_id]
      existingTile.terrain_name = terrain?.name
      existingTile.terrain_move_cost = terrain?.terrain_move_cost
    }
  })

  return oldTiles // this is the updatedTiles
}
