import { createAtomHydration } from "@/methods/functions/util/createAtomHydration"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/core/getAttributesSkillsServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/attributes/core/getPlayerSkillsServer"
import { getBuildingsBuildingsByKeyServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingsByKeyServer"
import { getBuildingsBuildingTypesServer } from "@/methods/server-fetchers/buildings/core/getBuildingsBuildingTypesServer"
import { getCitiesCityTilesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCityTilesByKeyServer"
import { getPlayerCityServer } from "@/methods/server-fetchers/cities/core/getPlayerCityServer"
import { getGetPlayerInventoryServer } from "@/methods/server-fetchers/inventory/core/getGetPlayerInventoryServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getCityData(clientCityId: number, playerId: number) {
  const city = await getPlayerCityServer({ playerId })

  const cityId = city.byKey[clientCityId].cityId

  if (!cityId) {
    return null
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

  const fallbackData = createSwrFallback(
    city,
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

  const atomHydrationData = createAtomHydration(
    city,
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
    { atomName: "playerIdAtom", byKey: playerId },
  )

  return {
    city,
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
    atomHydrationData,
    fallbackData,
  }
}
