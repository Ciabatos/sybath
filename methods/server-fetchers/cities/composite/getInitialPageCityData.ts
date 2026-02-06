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
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getInitialPageCityData(clientCityId: number, sessionUserId: number) {
  const activePlayer = await getActivePlayerServer({ userId: sessionUserId })
  const sessionPlayerId = activePlayer.raw[0].id
  const playerId = sessionPlayerId

  const city = await getPlayerCityServer({ playerId })

  if (!city || !city.byKey[clientCityId]) {
    return null
  }

  if (clientCityId != city.byKey[clientCityId].cityId) {
    return null
  }

  const cityId = clientCityId

  const [
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    // playerIventory,
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
    // getGetPlayerInventoryServer({ playerId }),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
    getBuildingsBuildingTypesServer(),
  ])

  const fallbackData = createSwrFallback(
    activePlayer,
    city,
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    // playerIventory,
    playerSkills,
    playerAbilities,
    buildingTypes,
  )

  const atomHydrationData = createAtomHydration(
    activePlayer,
    city,
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    // playerIventory,
    playerSkills,
    playerAbilities,
    buildingTypes,
  )

  return {
    activePlayer,
    city,
    cityTiles,
    terrainTypes,
    landscapeTypes,
    buildings,
    skills,
    abilities,
    // playerIventory,
    playerSkills,
    playerAbilities,
    buildingTypes,
    atomHydrationData,
    fallbackData,
  }
}
