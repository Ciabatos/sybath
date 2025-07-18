import { TCities, TCitiesByCoordinates } from "@/db/postgresMainDatabase/schemas/map/cities"
import { TDistricts, TDistrictsByCoordinates } from "@/db/postgresMainDatabase/schemas/map/districts"
import { TMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import type { TMapTiles } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { TPlayerVisibleMapData, TPlayerVisibleMapDataByCoordinates } from "@/db/postgresMainDatabase/schemas/map/playerVisibleMapData"
import type { TMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { produce } from "immer"

export interface TJoinedMapTile {
  mapTile: TMapTiles
  terrainTypes: TMapTerrainTypes
  landscapeTypes?: TMapLandscapeTypes
  cities?: TCities
  districts?: TDistricts
  playerVisibleMapData?: TPlayerVisibleMapData
  moveCost?: number
}

export type TJoinedMapTileByCoordinates = Record<string, TJoinedMapTile>

export function joinMapTiles(
  tiles: TMapTiles[],
  terrainTypes: TMapTerrainTypesById,
  landscapeTypes: TMapLandscapeTypesById,
  cities: TCitiesByCoordinates,
  districts: TDistrictsByCoordinates,
  playerVisibleMapData: TPlayerVisibleMapDataByCoordinates,
  options: {
    oldTilesToUpdate?: TJoinedMapTileByCoordinates
  } = {},
): TJoinedMapTileByCoordinates {
  const { oldTilesToUpdate } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  const createOrUpdateTile = (tile: TMapTiles): TJoinedMapTile => {
    const terrain = terrainTypes[tile.terrain_type_id]
    const landscape = tile.landscape_type_id != null ? landscapeTypes[tile.landscape_type_id] : undefined
    const city = cities?.[tile.x + "," + tile.y]
    const district = districts?.[tile.x + "," + tile.y]
    const playerData = playerVisibleMapData?.[tile.x + "," + tile.y]

    return {
      mapTile: tile,
      terrainTypes: terrain,
      landscapeTypes: landscape,
      cities: city,
      districts: district,
      playerVisibleMapData: playerData,
      moveCost: terrain.move_cost + (landscape?.move_cost ?? 0) + (city?.move_cost ?? 0) + (district?.move_cost ?? 0),
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
