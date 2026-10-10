// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerKnownPlayersParams } from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import type {
  TPlayerKnownPlayersRecordByOtherPlayerId,
  TPlayerKnownPlayers,
} from "@/db/postgresMainDatabase/schemas/knowledge/playerKnownPlayers"
import { fetchPlayerKnownPlayersService } from "@/methods/services/knowledge/fetchPlayerKnownPlayersService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TPlayerKnownPlayers[]
  byKey: TPlayerKnownPlayersRecordByOtherPlayerId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getPlayerKnownPlayersServer(
  params: TPlayerKnownPlayersParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerKnownPlayersService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/knowledge/rpc/get-player-known-players/${params.playerId}`,
    atomName: `playerKnownPlayersAtom`,
  }
}
