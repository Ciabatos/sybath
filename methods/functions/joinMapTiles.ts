import { TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTile } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { produce } from "immer"

export type TJoinedMapTile = {
  map_tile_id: number
  x: number
  y: number
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

// export interface TJoinedMapTile extends TMapTile, Partial<TMapTerrainTypesById>, Partial<TMapLandscapeTypesById>, Partial<TPlayerInventories> {}

export type TJoinedMapTileById = Record<string, TJoinedMapTile>

type JoinMapTilesOptions = {
  terrainTypes: TMapTerrainTypesById
  landscapeTypes: TMapLandscapeTypesById
  playerVisibleMapData?: TPlayerVisibleMapDataById
  oldTiles?: Record<string, TJoinedMapTile> // For client-side updates
}

export function joinMapTiles(tiles: TMapTile[], options: JoinMapTilesOptions): Record<string, TJoinedMapTile> {
  const { terrainTypes, landscapeTypes, playerVisibleMapData, oldTiles } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  const createOrUpdateTile = (tile: TMapTile): TJoinedMapTile => {
    const terrain = terrainTypes[tile.terrain_type_id]
    const landscape = tile.landscape_type_id != null ? landscapeTypes[tile.landscape_type_id] : undefined
    const playerPosition = playerVisibleMapData?.[tile.map_tile_id]

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
