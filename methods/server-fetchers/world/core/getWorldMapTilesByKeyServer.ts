// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import type { TWorldMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { fetchWorldMapTilesByKeyService } from "@/methods/services/world/fetchWorldMapTilesByKeyService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getWorldMapTilesByKeyServer(
  params: TWorldMapTilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchWorldMapTilesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/map-tiles/${params.mapId}`,
    atomName: `mapTilesAtom`,
  }
}
