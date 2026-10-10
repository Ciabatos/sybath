// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { fetchWorldMapTilesService } from "@/methods/services/world/fetchWorldMapTilesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getWorldMapTilesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchWorldMapTilesService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/map-tiles`,
    atomName: `mapTilesAtom`,
  }
}
