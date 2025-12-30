// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import { fetchWorldMapTilesService } from "@/methods/services/world/fetchWorldMapTilesService"

type TResult = {
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
  atomName: string
}

export async function getWorldMapTilesServer(): Promise<TResult> {
  const { record } = await fetchWorldMapTilesService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/map-tiles`,
    atomName: `mapTilesAtom`,
  }
}
