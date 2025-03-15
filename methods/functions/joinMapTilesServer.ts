import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"

export type TjoinedMapTile = {
  id: number
  x: number
  y: number
  terrain_type_id: number
  terrain_name?: string
  terrain_move_cost?: number
  image_url?: string
  map_field_id?: number
  player_image_url?: string
  player_name?: string
}

export function joinMapTilesServer(tiles: TMapTiles[], terrainTypes: Record<string, TMapTerrainTypes>): Record<string, TjoinedMapTile> {
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
          image_url: terrain?.image_url,
        },
      ]
    }),
  )
}
