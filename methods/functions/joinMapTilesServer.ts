import { TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"

export type TjoinedMapTile = {
  id: number
  x: number
  y: number
  map_field_id?: number
  terrain_type_id: number
  landscape_type_id?: number
  terrain_name?: string
  landscape_name?: string
  terrain_image_url?: string
  landscape_image_url?: string
  terrain_move_cost?: number
  player_image_url?: string
  player_name?: string
}

export function joinMapTilesServer(tiles: TMapTiles[], terrainTypes: Record<string, TMapTerrainTypes>, landscapeTypesById: Record<string, TMapLandscapeTypes>): Record<string, TjoinedMapTile> {
  return Object.fromEntries(
    tiles.map((tile) => {
      const key = `${tile.x},${tile.y}`
      const terrain = terrainTypes[tile.terrain_type_id]
      const landscape = tile.landscape_type_id != null ? landscapeTypesById[tile.landscape_type_id] : undefined

      return [
        key,
        {
          ...tile,
          terrain_name: terrain?.name,
          terrain_image_url: terrain?.image_url,
          landscape_name: landscape?.name,
          landscape_image_url: landscape?.image_url,
          terrain_move_cost: terrain?.terrain_move_cost + (landscape?.landscape_move_cost ?? 0),
        },
      ]
    }),
  )
}
