import { auth } from "@/auth"
import { joinCity } from "@/methods/functions/city/joinCity"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/core/getAttributesSkillsServer"
import { getBuildingsBuildingsByKeyServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingsByKeyServer"
import { getBuildingsBuildingTypesServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingTypesServer"
import { getCitiesCityTilesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCityTilesByKeyServer"
import { getGetPlayerInventoryServer } from "@/methods/server-fetchers/inventory/core/getGetPlayerInventoryServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getCityData(cityId: number) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return
  }

  const [
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    playerIventory,
    playerSkills,
    playerAbilities,
    buildingTypes,
  ] = await Promise.all([
    getCitiesCityTilesByKeyServer({ cityId }),
    getWorldTerrainTypesServer(),
    getWorldLandscapeTypesServer(),
    getBuildingsBuildingsByKeyServer({ cityId }),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getGetPlayerInventoryServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
    getBuildingsBuildingTypesServer(),
  ])

  const joinedCity = joinCity(
    cityTiles.byKey,
    terrainTypes.byKey,
    landscapeTypes.byKey,
    buildings.byKey,
    buildingTypes.byKey,
  )

  const fallbackData = createSwrFallback(
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    playerIventory,
    playerSkills,
    playerAbilities,
    buildingTypes,
  )

  return {
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    playerIventory,
    playerSkills,
    playerAbilities,
    buildingTypes,
    joinedCity,
    fallbackData,
  }
}
