"use server"

import { joinMap } from "@/methods/functions/map/joinMap"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCitiesByKeyServer"
import { getDistrictsDistrictsByKeyServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictsByKeyServer"
import { getDistrictsDistrictTypesServer } from "@/methods/server-fetchers/districts/core/getDistrictsDistrictTypesServer"
import { getPlayerPositionServer } from "@/methods/server-fetchers/world/core/getPlayerPositionServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/core/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

export async function getJoinedMap(mapId: number, playerId: number) {
  const [terrainTypes, mapTiles, landscapeTypes, cities, districts, districtTypes, playerPosition] = await Promise.all([
    getWorldTerrainTypesServer(),
    getWorldMapTilesByKeyServer({ mapId }),
    getWorldLandscapeTypesServer(),
    getCitiesCitiesByKeyServer({ mapId }),
    getDistrictsDistrictsByKeyServer({ mapId }),
    getDistrictsDistrictTypesServer(),
    getPlayerPositionServer({ mapId, playerId }),
  ])

  const joinedMap = joinMap({
    tiles: mapTiles.byKey,
    terrainTypes: terrainTypes.byKey,
    landscapeTypes: landscapeTypes.byKey,
    cities: cities.byKey,
    districts: districts.byKey,
    districtTypes: districtTypes.byKey,
    playerPosition: playerPosition.byKey,
  })

  return { terrainTypes, mapTiles, landscapeTypes, cities, districts, districtTypes, playerPosition, joinedMap }
}
