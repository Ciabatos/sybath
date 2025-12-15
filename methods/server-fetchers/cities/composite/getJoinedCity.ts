"use server"

import { joinCity } from "@/methods/functions/city/joinCity"
import { getBuildingsBuildingsByKeyServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingsByKeyServer"
import { getBuildingsBuildingTypesServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingTypesServer"
import { getCitiesCityTilesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCityTilesByKeyServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getJoinedCity(cityId: number) {
  const [cityTiles, terrainTypes, landscapeTypes, buildings, buildingTypes] = await Promise.all([
    getCitiesCityTilesByKeyServer({ cityId }),
    getWorldTerrainTypesServer(),
    getWorldLandscapeTypesServer(),
    getBuildingsBuildingsByKeyServer({ cityId }),
    getBuildingsBuildingTypesServer(),
  ])

  const joinedCity = joinCity({
    tiles: cityTiles.byKey,
    terrainTypes: terrainTypes.byKey,
    landscapeTypes: landscapeTypes.byKey,
    buildings: buildings.byKey,
    buildingsTypes: buildingTypes.byKey,
  })

  return { cityTiles, terrainTypes, landscapeTypes, buildings, buildingTypes, joinedCity }
}
