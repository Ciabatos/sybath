// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TKnownMapTilesParams } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import type { TKnownMapTilesRecordByXY, TKnownMapTiles } from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { fetchKnownMapTilesService } from "@/methods/services/world/fetchKnownMapTilesService"

type TResult = {
  raw: TKnownMapTiles[]
  byKey: TKnownMapTilesRecordByXY
  apiPath: string
  atomName: string
}

export async function getKnownMapTilesServer(
  params: TKnownMapTilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchKnownMapTilesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-known-map-tiles/${params.mapId}/${params.playerId}`,
    atomName: `knownMapTilesAtom`,
  }
}
