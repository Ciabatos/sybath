// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { fetchWorldMapTilesByKey } from "@/methods/functions/services/world/fetchWorldMapTilesByKey"

type TResult = {
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: string
}

export async function getWorldMapTilesByKeyServer(params: TWorldMapTilesParams): Promise<TResult> {
  const { record } = await fetchWorldMapTilesByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/map-tiles/${params.mapId}`,
    atomName: `mapTilesAtom`,
  }
}
