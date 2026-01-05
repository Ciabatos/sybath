// ----------------------------
// joinMap.ts (generator-friendly)

import { TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TPlayerPositionRecordByXY } from "@/db/postgresMainDatabase/schemas/world/playerPosition"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TJoinMap, TJoinMapByXY } from "@/methods/functions/deprecated/joinMap3"

// ----------------------------
export function joinMap({
  tiles,
  terrainTypes,
  landscapeTypes,
  cities,
  districts,
  districtTypes,
  playerPosition,
  options = {},
}: TJoinMapParams): TJoinMapByXY {
  const { oldDataToUpdate } = options
  const entries = Object.entries(tiles)
  const newMap: TJoinMapByXY = oldDataToUpdate ? { ...oldDataToUpdate } : {}

  entries.forEach(([key, tile]) => {
    // ----------------------------
    // 1️⃣ Zbieranie danych (lookup)
    // ----------------------------
    const joinedData = getJoinedData({
      key,
      tile,
      terrainTypes,
      landscapeTypes,
      cities,
      districts,
      districtTypes,
      playerPosition,
    })

    const oldData = oldDataToUpdate?.[key]

    // ----------------------------
    // 2️⃣ Sprawdzenie zmian
    // ----------------------------
    const changed =
      !oldData ||
      Object.keys(joinedData).some((field) => {
        const oldValue = (oldData as any)[fieldMapping[field]] // fieldMapping np. { newTiles: 'tiles', newTerrainTypes: 'terrainTypes' }
        return oldValue !== (joinedData as any)[field]
      })

    if (changed) {
      // ----------------------------
      // 3️⃣ Budowanie nowego obiektu
      // ----------------------------
      newMap[key] = buildNewMap(joinedData)
    }
  })

  return newMap
}

// ----------------------------
// Funkcja lookup danych
// ----------------------------
function getJoinedData({
  key,
  tile,
  terrainTypes,
  landscapeTypes,
  cities,
  districts,
  districtTypes,
  playerPosition,
}: {
  key: string
  tile: TWorldMapTilesRecordByXY[keyof TWorldMapTilesRecordByXY]
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  cities: TCitiesCitiesRecordByMapTileXMapTileY
  districts: TDistrictsDistrictsRecordByMapTileXMapTileY
  districtTypes: TDistrictsDistrictTypesRecordById
  playerPosition: TPlayerPositionRecordByXY
}) {
  return {
    newTiles: tile,
    newTerrainTypes: terrainTypes[tile.terrainTypeId],
    newLandscapeTypes: tile.landscapeTypeId ? landscapeTypes[tile.landscapeTypeId] : undefined,
    newCities: cities[key],
    newDistricts: districts[key],
    newDistrictTypes: districts[key] ? districtTypes[districts[key].districtTypeId] : undefined,
    newPlayerPosition: playerPosition[key],
  }
}

// ----------------------------
// Funkcja budująca finalny obiekt
// ----------------------------
function buildNewMap(joinedData: ReturnType<typeof getJoinedData>): TJoinMap {
  return Object.entries(joinedData).reduce<TJoinMap>(
    (acc, [key, value]) => {
      if (value !== undefined) {
        // mapowanie kluczy generator-friendly
        const mapKey = keyMapping[key] ?? key // keyMapping np. { newTiles: 'tiles', newTerrainTypes: 'terrainTypes', ... }
        acc[mapKey] = value
      }
      return acc
    },
    {
      moveCost:
        (joinedData.newTerrainTypes?.moveCost ?? 0) +
        (joinedData.newLandscapeTypes?.moveCost ?? 0) +
        (joinedData.newCities?.moveCost ?? 0),
      tiles: joinedData.newTiles, // tiles zawsze potrzebne
      terrainTypes: joinedData.newTerrainTypes, // teren zawsze potrzebny
    },
  )
}

// ----------------------------
// Mapowania kluczy dla generatora Plop.js
// ----------------------------
const keyMapping: Record<string, keyof TJoinMap> = {
  newTiles: "tiles",
  newTerrainTypes: "terrainTypes",
  newLandscapeTypes: "landscapeTypes",
  newCities: "cities",
  newDistricts: "districts",
  newDistrictTypes: "districtTypes",
  newPlayerPosition: "playerPosition",
}
