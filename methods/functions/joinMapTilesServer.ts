import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/mapTerrainTypes"
import type { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapsFieldsPlayerPosition"

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

export function joinMapTilesServer(tiles: TMapTiles[], playerPosition: Record<string, TMapsFieldsPlayerPosition>, terrainTypes: Record<string, TMapTerrainTypes>): Record<string, TjoinedMapTile> {
  return Object.fromEntries(
    tiles.map((tile) => {
      const key = `${tile.x},${tile.y}`
      const terrain = terrainTypes[tile.terrain_type_id]
      const player = playerPosition[tile.id]
      return [
        key,
        {
          ...tile,
          terrain_name: terrain?.name,
          terrain_move_cost: terrain?.terrain_move_cost,
          image_url: terrain?.image_url,
          player_id: player?.player_name,
          player_name: player?.player_image_url,
        },
      ]
    }),
  )
}
