import { joinCity } from "@/methods/functions/city/joinCity"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/core/getAttributesSkillsServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/attributes/core/getPlayerSkillsServer"
import { getBuildingsBuildingsByKeyServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingsByKeyServer"
import { getBuildingsBuildingTypesServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingTypesServer"
import { getCitiesCityTilesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCityTilesByKeyServer"
import { getGetPlayerInventoryServer } from "@/methods/server-fetchers/inventory/core/getGetPlayerInventoryServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getCityData(cityId: number, playerId: number) {
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

  const joinedCity = joinCity({
    tiles: cityTiles.byKey,
    terrainTypes: terrainTypes.byKey,
    landscapeTypes: landscapeTypes.byKey,
    buildings: buildings.byKey,
    buildingsTypes: buildingTypes.byKey,
  })

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
