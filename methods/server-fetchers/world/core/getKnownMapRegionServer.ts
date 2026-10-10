// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TKnownMapRegionParams } from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import type {
  TKnownMapRegionRecordByMapTileXMapTileY,
  TKnownMapRegion,
} from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { fetchKnownMapRegionService } from "@/methods/services/world/fetchKnownMapRegionService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TKnownMapRegion[]
  byKey: TKnownMapRegionRecordByMapTileXMapTileY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getKnownMapRegionServer(
  params: TKnownMapRegionParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchKnownMapRegionService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/rpc/get-known-map-region/${params.mapId}/${params.playerId}/${params.regionType}`,
    atomName: `knownMapRegionAtom`,
  }
}
