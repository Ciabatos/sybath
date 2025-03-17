import { TMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { TMapsFieldsPlayerPosition } from "@/db/postgresMainDatabase/schemas/map/views/mapTilesPlayerPosition"
import { produce } from "immer"

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

type JoinMapTilesOptions = {
  terrainTypes: Record<number, TMapTerrainTypes>
  landscapeTypes: Record<number, TMapLandscapeTypes>
  mapTilesPlayerPosition?: Record<number, TMapsFieldsPlayerPosition>
  oldTiles?: Record<string, TjoinedMapTile> // For client-side updates
}

export function joinMapTiles(tiles: TMapTiles[], options: JoinMapTilesOptions): Record<string, TjoinedMapTile> {
  const { terrainTypes, landscapeTypes, mapTilesPlayerPosition, oldTiles } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  const createOrUpdateTile = (tile: TMapTiles): TjoinedMapTile => {
    const terrain = terrainTypes[tile.terrain_type_id]
    const landscape = tile.landscape_type_id != null ? landscapeTypes[tile.landscape_type_id] : undefined
    const playerPosition = mapTilesPlayerPosition?.[tile.id]

    return {
      ...tile,
      terrain_name: terrain?.name,
      terrain_image_url: terrain?.image_url,
      landscape_name: landscape?.name,
      landscape_image_url: landscape?.image_url,
      terrain_move_cost: terrain?.terrain_move_cost + (landscape?.landscape_move_cost ?? 0),
      player_name: playerPosition?.player_name,
      player_image_url: playerPosition?.player_image_url,
    }
  }

  // To jest render block
  // (client-side behavior)
  if (oldTiles) {
    return produce(oldTiles, (draft) => {
      tiles.forEach((tile) => {
        const key = `${tile.x},${tile.y}`
        if (draft[key]) {
          draft[key] = createOrUpdateTile(tile)
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(
      tiles.map((tile) => {
        const key = `${tile.x},${tile.y}`
        return [key, createOrUpdateTile(tile)]
      }),
    )
  }
}
