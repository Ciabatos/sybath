import { joinMap } from "@/methods/functions/map/joinMap"
import { createSwrFallback } from "@/methods/functions/util/createSwrFallback"
import { getAttributesAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getAttributesAbilitiesServer"
import { getAttributesSkillsServer } from "@/methods/server-fetchers/attributes/core/getAttributesSkillsServer"
import { getPlayerAbilitiesServer } from "@/methods/server-fetchers/attributes/core/getPlayerAbilitiesServer"
import { getPlayerSkillsServer } from "@/methods/server-fetchers/attributes/core/getPlayerSkillsServer"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCitiesByKeyServer"
import { getDistrictsDistrictsByKeyServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictsByKeyServer"
import { getDistrictsDistrictTypesServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictTypesServer"
import { getGetPlayerInventoryServer } from "@/methods/server-fetchers/inventory/core/getGetPlayerInventoryServer"
import { getPlayerPositionServer } from "@/methods/server-fetchers/world/core/getPlayerPositionServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/core/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getMapData(mapId: number, playerId: number) {
  const [
    terrainTypes,
    mapTiles,
    landscapeTypes,
    cities,
    districts,
    districtTypes,
    getPlayerPosition,
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
    getGetPlayerInventoryServer({ playerId }),
  ])

  const joinedMap = joinMap({
    tiles: mapTiles.byKey,
    terrainTypes: terrainTypes.byKey,
    landscapeTypes: landscapeTypes.byKey,
    cities: cities.byKey,
    districts: districts.byKey,
    districtTypes: districtTypes.byKey,
    getPlayerPosition: getPlayerPosition.byKey,
  })

  const fallbackData = createSwrFallback(
    mapTiles,
    skills,
    abilities,
    cities,
    districts,
    districtTypes,
    getPlayerPosition,
    playerSkills,
    playerAbilities,
    playerIventory,
    terrainTypes,
    landscapeTypes,
  )

  return {
    terrainTypes,
    mapTiles,
    landscapeTypes,
    cities,
    districts,
    districtTypes,
    skills,
    abilities,
    getPlayerPosition,
    playerSkills,
    playerAbilities,
    playerIventory,
    joinedMap,
    fallbackData,
  }
}
