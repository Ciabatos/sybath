// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTilesByKey } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles" 
import type { TWorldMapTiles, TWorldMapTilesRecordByMapIdXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"

export async function getWorldMapTilesByKeyServer( params: TWorldMapTilesParams): Promise<{
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByMapIdXY
  apiPath: string
}> {
  const getWorldMapTilesByKeyData = await getWorldMapTilesByKey(params)

  const data = getWorldMapTilesByKeyData ? (arrayToObjectKey(["mapId", "x", "y"], getWorldMapTilesByKeyData) as TWorldMapTilesRecordByMapIdXY) : {}

  return { raw: getWorldMapTilesByKeyData, byKey: data, apiPath: `/api/world/map-tiles/${params.mapId}/${params.x}/${params.y}` }
}
