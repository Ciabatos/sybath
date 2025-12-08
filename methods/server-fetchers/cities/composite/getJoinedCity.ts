"use server"

import { auth } from "@/auth"
import { joinCity } from "@/methods/functions/city/joinCity"
import { getBuildingsBuildingsByKeyServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingsByKeyServer"
import { getBuildingsBuildingTypesServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingTypesServer"
import { getCitiesCityTilesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCityTilesByKeyServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getJoinedCity(cityId: number) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return
  }

  const [cityTiles, terrainTypes, landscapeTypes, buildings, buildingTypes] = await Promise.all([
    getCitiesCityTilesByKeyServer({ cityId }),
    getWorldTerrainTypesServer(),
    getWorldLandscapeTypesServer(),
    getBuildingsBuildingsByKeyServer({ cityId }),
    getBuildingsBuildingTypesServer(),
  ])

  const joinedCity = joinCity(cityTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, buildings.byKey, buildingTypes.byKey)

  return { cityTiles, terrainTypes, landscapeTypes, buildings, buildingTypes, joinedCity }
}
