"use server"

import { auth } from "@/auth"
import { joinMap } from "@/methods/functions/map/joinMap"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCitiesByKeyServer"
import { getDistrictsDistrictsByKeyServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictsByKeyServer"
import { getDistrictsDistrictTypesServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictTypesServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/core/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"
import { getPlayerVisibleMapDataServer } from "@/methods/server-fetchers/world/getPlayerVisibleMapDataServer"

export async function getJoinedMap(mapId: number) {
  const session = await auth()
  const playerId = session?.user?.playerId

  if (!playerId || isNaN(playerId)) {
    return
  }

  const [terrainTypes, mapTiles, landscapeTypes, cities, districts, districtTypes, playerVisibleMapData] = await Promise.all([
    getWorldTerrainTypesServer(),
    getWorldMapTilesByKeyServer({ mapId }),
    getWorldLandscapeTypesServer(),
    getCitiesCitiesByKeyServer({ mapId }),
    getDistrictsDistrictsByKeyServer({ mapId }),
    getDistrictsDistrictTypesServer(),
    getPlayerVisibleMapDataServer({ playerId }),
  ])

  const joinedMap = joinMap(mapTiles.byKey, terrainTypes.byKey, landscapeTypes.byKey, cities.byKey, districts.byKey, districtTypes.byKey, playerVisibleMapData.byKey)

  return { terrainTypes, mapTiles, landscapeTypes, cities, districts, districtTypes, playerVisibleMapData, joinedMap }
}
