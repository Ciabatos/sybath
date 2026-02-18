// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TWorldMapTilesMapRegions,
  TWorldMapTilesMapRegionsRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import { fetchWorldMapTilesMapRegionsService } from "@/methods/services/world/fetchWorldMapTilesMapRegionsService"

type TResult = {
  raw: TWorldMapTilesMapRegions[]
  byKey: TWorldMapTilesMapRegionsRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getWorldMapTilesMapRegionsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchWorldMapTilesMapRegionsService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/map-tiles-map-regions`,
    atomName: `mapTilesMapRegionsAtom`,
  }
}
