import { TCityBuildings, TCityBuildingsMapCoordinates } from "@/db/postgresMainDatabase/schemas/map/tables/buildings"
import { TCityTiles } from "@/db/postgresMainDatabase/schemas/map/tables/cityTiles"
import { TMapLandscapeTypes, TMapLandscapeTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/landscapeTypes"
import type { TMapTerrainTypes, TMapTerrainTypesById } from "@/db/postgresMainDatabase/schemas/map/tables/terrainTypes"
import { produce } from "immer"

export interface TJoinedCityTiles {
  cityTiles: TCityTiles
  terrainTypes: TMapTerrainTypes
  landscapeTypes?: TMapLandscapeTypes
  buildings?: TCityBuildings
}

export type TJoinedCityTilesById = Record<string, TJoinedCityTiles>

export function joinCityTiles(
  tiles: TCityTiles[],
  terrainTypes: TMapTerrainTypesById,
  landscapeTypes: TMapLandscapeTypesById,
  buildings: TCityBuildingsMapCoordinates,
  options: {
    oldTilesToUpdate?: TJoinedCityTilesById
  } = {},
): TJoinedCityTilesById {
  const { oldTilesToUpdate } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  const createOrUpdateTile = (tile: TCityTiles): TJoinedCityTiles => {
    const terrain = terrainTypes[tile.terrain_type_id]
    const landscape = tile.landscape_type_id != null ? landscapeTypes[tile.landscape_type_id] : undefined
    const building = buildings?.[tile.x + "," + tile.y]

    return {
      cityTiles: tile,
      terrainTypes: terrain,
      landscapeTypes: landscape,
      buildings: building,
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
