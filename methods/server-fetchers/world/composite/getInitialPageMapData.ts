"use server"

import { createAtomHydration } from "@/methods/functions/util/createAtomHydration"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/core/getAttributesSkillsServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/attributes/core/getPlayerSkillsServer"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCitiesByKeyServer"
import { getDistrictsDistrictsByKeyServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictsByKeyServer"
import { getDistrictsDistrictTypesServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictTypesServer"
import { getPlayerInventoryServer } from "@/methods/server-fetchers/inventory/core/getPlayerInventoryServer"
import { getActivePlayerServer } from "@/methods/server-fetchers/players/core/getActivePlayerServer"
import { getKnownMapTilesServer } from "@/methods/server-fetchers/world/core/getKnownMapTilesServer"
import { getKnownPlayersPositionsServer } from "@/methods/server-fetchers/world/core/getKnownPlayersPositionsServer"
import { getPlayerMapServer } from "@/methods/server-fetchers/world/core/getPlayerMapServer"
import { getPlayerPositionServer } from "@/methods/server-fetchers/world/core/getPlayerPositionServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getInitialPageMapData(clientMapId: number, sessionUserId: number) {
  const activePlayer = await getActivePlayerServer({ userId: sessionUserId })
  const sessionPlayerId = activePlayer.raw[0].id
  const playerId = sessionPlayerId

  const map = await getPlayerMapServer({ playerId })

  if (!map || !map.byKey[clientMapId]) {
    return null
  }

  if (clientMapId != map.byKey[clientMapId].mapId) {
    return null
  }

  const mapId = clientMapId

  const [
    terrainTypes,
    mapTiles,
    landscapeTypes,
    cities,
    districts,
    districtTypes,
    playerPosition,
    knownPlayersPositions,
    skills,
    abilities,
    playerSkills,
    playerAbilities,
    playerIventory,
  ] = await Promise.all([
    getWorldTerrainTypesServer(),
    getKnownMapTilesServer({ mapId, playerId }),
    getWorldLandscapeTypesServer(),
    getCitiesCitiesByKeyServer({ mapId }),
    getDistrictsDistrictsByKeyServer({ mapId }),
    getDistrictsDistrictTypesServer(),
    getPlayerPositionServer({ mapId, playerId }),
    getKnownPlayersPositionsServer({ mapId, playerId }),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
    getPlayerInventoryServer({ playerId }),
  ])

  const fallbackData = createSwrFallback(
    activePlayer,
    map,
    mapTiles,
    skills,
    abilities,
    cities,
    districts,
    districtTypes,
    playerPosition,
    knownPlayersPositions,
    playerSkills,
    playerAbilities,
    playerIventory,
    terrainTypes,
    landscapeTypes,
  )

  const atomHydrationData = createAtomHydration(
    activePlayer,
    map,
    mapTiles,
    skills,
    abilities,
    cities,
    districts,
    districtTypes,
    playerPosition,
    knownPlayersPositions,
    playerSkills,
    playerAbilities,
    playerIventory,
    terrainTypes,
    landscapeTypes,
  )

  return {
    activePlayer,
    map,
    terrainTypes,
    mapTiles,
    landscapeTypes,
    cities,
    districts,
    districtTypes,
    skills,
    abilities,
    playerPosition,
    knownPlayersPositions,
    playerSkills,
    playerAbilities,
    playerIventory,
    atomHydrationData,
    fallbackData,
  }
}
