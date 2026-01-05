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
import { getPlayerPositionServer } from "@/methods/server-fetchers/world/core/getPlayerPositionServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldMapsServer } from "@/methods/server-fetchers/world/core/getWorldMapsServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/core/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getMapData(clientMapId: number, playerId: number) {
  const map = await getWorldMapsServer()
  const mapId = map.raw[0].id
  if (mapId !== clientMapId) {
    return null
  }

  const [
    terrainTypes,
    mapTiles,
    landscapeTypes,
    cities,
    districts,
    districtTypes,
    playerPosition,
    skills,
    abilities,
    playerSkills,
    playerAbilities,
    playerIventory,
  ] = await Promise.all([
    getWorldTerrainTypesServer(),
    getWorldMapTilesByKeyServer({ mapId }),
    getWorldLandscapeTypesServer(),
    getCitiesCitiesByKeyServer({ mapId }),
    getDistrictsDistrictsByKeyServer({ mapId }),
    getDistrictsDistrictTypesServer(),
    getPlayerPositionServer({ mapId, playerId }),
    getAttributesSkillsServer(),
    getAttributesAbilitiesServer(),
    getPlayerSkillsServer({ playerId }),
    getPlayerAbilitiesServer({ playerId }),
    getPlayerInventoryServer({ playerId }),
  ])

  const fallbackData = createSwrFallback(
    map,
    mapTiles,
    skills,
    abilities,
    cities,
    districts,
    districtTypes,
    playerPosition,
    playerSkills,
    playerAbilities,
    playerIventory,
    terrainTypes,
    landscapeTypes,
  )

  const atomHydrationData = createAtomHydration(
    map,
    mapTiles,
    skills,
    abilities,
    cities,
    districts,
    districtTypes,
    playerPosition,
    playerSkills,
    playerAbilities,
    playerIventory,
    terrainTypes,
    landscapeTypes,
    { atomName: "playerIdAtom", byKey: playerId },
  )

  return {
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
    playerSkills,
    playerAbilities,
    playerIventory,
    atomHydrationData,
    fallbackData,
  }
}
