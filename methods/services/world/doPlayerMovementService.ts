// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - serviceGetMethodAction.hbs
"use server"

import { TDoPlayerMovementParams, doPlayerMovement } from "@/db/postgresMainDatabase/schemas/world/doPlayerMovement"
import { pathFromPointToPoint } from "@/methods/functions/map/pathFromPointToPoint"
import { getCitiesCitiesByKeyServer } from "@/methods/server-fetchers/cities/core/getCitiesCitiesByKeyServer"
import { getWorldLandscapeTypesServer } from "@/methods/server-fetchers/world/core/getWorldLandscapeTypesServer"
import { getWorldMapsServer } from "@/methods/server-fetchers/world/core/getWorldMapsServer"
import { getWorldMapTilesByKeyServer } from "@/methods/server-fetchers/world/core/getWorldMapTilesByKeyServer"
import { getWorldTerrainTypesServer } from "@/methods/server-fetchers/world/core/getWorldTerrainTypesServer"

//MANUAL CODE - START

export type TDoPlayerMovementServiceParams = {
  playerId: number
  startX: number
  startY: number
  endX: number
  endY: number
}

//MANUAL CODE - END

export async function doPlayerMovementService(params: TDoPlayerMovementServiceParams) {
  //MANUAL CODE - START

  const mapId = await getWorldMapsServer()
  const mapTiles = await getWorldMapTilesByKeyServer({ mapId: mapId.raw[0].id })
  const terrainTypes = await getWorldTerrainTypesServer()
  const landscapeTypes = await getWorldLandscapeTypesServer()
  const cities = await getCitiesCitiesByKeyServer({ mapId: mapId.raw[0].id })

  if (!mapTiles) {
    return
  }
  const path = pathFromPointToPoint({
    startX: params.startX,
    startY: params.startY,
    endX: params.endX,
    endY: params.endY,
    mapTiles: mapTiles.byKey,
    terrainTypes: terrainTypes.byKey,
    landscapeTypes: landscapeTypes.byKey,
    cities: cities.byKey,
  })

  //MANUAL CODE - END

  const data: TDoPlayerMovementParams = {
    playerId: params.playerId,
    path: path,
  }

  try {
    const result = await doPlayerMovement(data)
    return result
  } catch (error) {
    console.error("Error doPlayerMovementService :", error)
    return "Failed to doPlayerMovementService"
  }
}
