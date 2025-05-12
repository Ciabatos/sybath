import { TPlayerVisibleMapData, TPlayerVisibleMapDataById } from "@/db/postgresMainDatabase/schemas/map/functions/playerVisibleMapData"
import { TMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTile } from "@/db/postgresMainDatabase/schemas/map/tables/mapTiles"
import type { TMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { produce } from "immer"

export interface TJoinedMapTile {
  mapTile: TMapTile
  terrainTypes: TMapTerrainTypes
  landscapeTypes?: TMapLandscapeTypes
  playerVisibleMapData?: TPlayerVisibleMapData
  moveCost?: number
}

export type TJoinedMapTileById = Record<string, TJoinedMapTile>

export function joinMapTiles(
  tiles: TMapTile[],
  terrainTypes: TMapTerrainTypesById,
  landscapeTypes: TMapLandscapeTypesById,
  playerVisibleMapData: TPlayerVisibleMapDataById,
  options: {
    oldTilesToUpdate?: Record<string, TJoinedMapTile>
  } = {},
): Record<string, TJoinedMapTile> {
  const { oldTilesToUpdate } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  const createOrUpdateTile = (tile: TMapTile): TJoinedMapTile => {
    const terrain = terrainTypes[tile.terrain_type_id]
    const landscape = tile.landscape_type_id != null ? landscapeTypes[tile.landscape_type_id] : undefined
    const playerData = playerVisibleMapData?.[tile.x + "," + tile.y]

    return {
      mapTile: tile,
      terrainTypes: terrain,
      landscapeTypes: landscape,
      playerVisibleMapData: playerData,
      moveCost: terrain.terrain_move_cost + (landscape?.landscape_move_cost ?? 0),
    }
  }

  // To jest render block
  // (client-side behavior)
  if (oldTilesToUpdate) {
    return produce(oldTilesToUpdate, (draft) => {
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
