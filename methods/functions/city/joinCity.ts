import { TBuildingsBuildingsRecordByCityTileXCityTileY } from "@/db/postgresMainDatabase/schemas/buildings/buildings"
import { TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { produce } from "immer"

type TJoinCityParams = {
  tiles: TCitiesCityTilesRecordByXY
  terrainTypes: TWorldTerrainTypesRecordById
  landscapeTypes: TWorldLandscapeTypesRecordById
  buildings: TBuildingsBuildingsRecordByCityTileXCityTileY
  buildingsTypes: TBuildingsBuildingTypesRecordById
  options: {
    oldDataToUpdate?: TJoinCityByXY
  }
}
export interface TJoinCity {
  tiles: TCitiesCityTilesRecordByXY[keyof TCitiesCityTilesRecordByXY]
  terrainTypes: TWorldTerrainTypesRecordById[keyof TWorldTerrainTypesRecordById]
  landscapeTypes?: TWorldLandscapeTypesRecordById[keyof TWorldLandscapeTypesRecordById]
  buildings?: TBuildingsBuildingsRecordByCityTileXCityTileY[keyof TBuildingsBuildingsRecordByCityTileXCityTileY]
  buildingTypes?: TBuildingsBuildingTypesRecordById[keyof TBuildingsBuildingTypesRecordById]
}

export type TJoinCityByXY = Record<string, TJoinCity>

export function joinCity({
  tiles,
  terrainTypes,
  landscapeTypes,
  buildings,
  buildingsTypes,
  options = {},
}: TJoinCityParams): TJoinCityByXY {
  const { oldDataToUpdate } = options

  // to jest funkcja pomocnicza dla bloku poniżej
  function createOrUpdate(mainData: TCitiesCityTilesRecordByXY[keyof TCitiesCityTilesRecordByXY]): TJoinCity {
    const terrainTypesData = terrainTypes[mainData.terrainTypeId]
    const landscapeTypesData = mainData.landscapeTypeId ? landscapeTypes[mainData.landscapeTypeId] : undefined
    const buildingsData = mainData.cityId ? buildings[`${mainData.x},${mainData.y}`] : undefined
    const buildingTypesData = buildingsData ? buildingsTypes[buildingsData.buildingTypeId] : undefined

    return {
      tiles: mainData,
      terrainTypes: terrainTypesData,
      landscapeTypes: landscapeTypesData,
      buildings: buildingsData,
      buildingTypes: buildingTypesData,
    }
  }
  const dataEntries = Object.entries(tiles)

  // To jest render block
  // (client-side behavior)
  if (oldDataToUpdate) {
    return produce(oldDataToUpdate, (draft) => {
      dataEntries.forEach(([key, data]) => {
        if (draft[key]) {
          draft[key] = createOrUpdate(data)
        }
      })
    })
  } else {
    // (server-side behavior)
    return Object.fromEntries(dataEntries.map(([key, data]) => [key, createOrUpdate(data)]))
  }
}
