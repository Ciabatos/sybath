// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTilesByKey } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"

export async function getWorldMapTilesByKeyServer(params: TWorldMapTilesParams): Promise<{
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: string
}> {
  const getWorldMapTilesByKeyData = await getWorldMapTilesByKey(params)

  const data = getWorldMapTilesByKeyData
    ? (arrayToObjectKey(["x", "y"], getWorldMapTilesByKeyData) as TWorldMapTilesRecordByXY)
    : {}

  return {
    raw: getWorldMapTilesByKeyData,
    byKey: data,
    apiPath: `/api/world/map-tiles/${params.mapId}`,
    atomName: `mapTilesAtom`,
  }
}
