// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TWorldMapTilesMapRegions,
  TWorldMapTilesMapRegionsRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import type { TWorldMapTilesMapRegionsParams } from "@/db/postgresMainDatabase/schemas/world/mapTilesMapRegions"
import { fetchWorldMapTilesMapRegionsByKeyService } from "@/methods/services/world/fetchWorldMapTilesMapRegionsByKeyService"

type TResult = {
  raw: TWorldMapTilesMapRegions[]
  byKey: TWorldMapTilesMapRegionsRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getWorldMapTilesMapRegionsByKeyServer(
  params: TWorldMapTilesMapRegionsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchWorldMapTilesMapRegionsByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/map-tiles-map-regions/${params.mapId}`,
    atomName: `mapTilesMapRegionsAtom`,
  }
}
