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

export function joinMapTilesServer(tiles: TMapTiles[], terrainTypes: TMapTerrainTypes[]): Record<string, TjoinedMapTile> {
  return Object.fromEntries(
    tiles.map((tile) => {
      const key = `${tile.x},${tile.y}`
      const terrain = terrainTypes[tile.terrain_type_id]
      return [
        key,
        {
          ...tile,
          terrain_name: terrain?.name,
          terrain_move_cost: terrain?.terrain_move_cost,
        },
      ]
    }),
  )
}
