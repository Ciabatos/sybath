// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TKnownMapTilesResourcesOnMapParams } from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import type {
  TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY,
  TKnownMapTilesResourcesOnMap,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnMap"
import { fetchKnownMapTilesResourcesOnMapService } from "@/methods/services/world/fetchKnownMapTilesResourcesOnMapService"

type TResult = {
  raw: TKnownMapTilesResourcesOnMap[]
  byKey: TKnownMapTilesResourcesOnMapRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getKnownMapTilesResourcesOnMapServer(
  params: TKnownMapTilesResourcesOnMapParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchKnownMapTilesResourcesOnMapService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-known-map-tiles-resources-on-map/${params.mapId}/${params.playerId}`,
    atomName: `knownMapTilesResourcesOnMapAtom`,
  }
}
