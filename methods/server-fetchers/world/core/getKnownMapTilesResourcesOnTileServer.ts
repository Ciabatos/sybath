// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TKnownMapTilesResourcesOnTileParams } from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import type {
  TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId,
  TKnownMapTilesResourcesOnTile,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTilesResourcesOnTile"
import { fetchKnownMapTilesResourcesOnTileService } from "@/methods/services/world/fetchKnownMapTilesResourcesOnTileService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TKnownMapTilesResourcesOnTile[]
  byKey: TKnownMapTilesResourcesOnTileRecordByMapTilesResourceId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getKnownMapTilesResourcesOnTileServer(
  params: TKnownMapTilesResourcesOnTileParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchKnownMapTilesResourcesOnTileService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/rpc/get-known-map-tiles-resources-on-tile/${params.mapId}/${params.mapTileX}/${params.mapTileY}/${params.playerId}`,
    atomName: `knownMapTilesResourcesOnTileAtom`,
  }
}
