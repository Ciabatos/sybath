// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TKnownPlayersPositionsParams } from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import type {
  TKnownPlayersPositionsRecordByXY,
  TKnownPlayersPositions,
} from "@/db/postgresMainDatabase/schemas/world/knownPlayersPositions"
import { fetchKnownPlayersPositionsService } from "@/methods/services/world/fetchKnownPlayersPositionsService"

type TResult = {
  raw: TKnownPlayersPositions[]
  byKey: TKnownPlayersPositionsRecordByXY
  apiPath: string
  atomName: string
}

export async function getKnownPlayersPositionsServer(
  params: TKnownPlayersPositionsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchKnownPlayersPositionsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/rpc/get-known-players-positions/${params.mapId}/${params.playerId}`,
    atomName: `knownPlayersPositionsAtom`,
  }
}
