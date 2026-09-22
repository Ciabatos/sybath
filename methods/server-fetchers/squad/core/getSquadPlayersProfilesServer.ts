// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TSquadPlayersProfilesParams } from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import type {
  TSquadPlayersProfilesRecordByOtherPlayerId,
  TSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import { fetchSquadPlayersProfilesService } from "@/methods/services/squad/fetchSquadPlayersProfilesService"

type TResult = {
  raw: TSquadPlayersProfiles[]
  byKey: TSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

export async function getSquadPlayersProfilesServer(
  params: TSquadPlayersProfilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchSquadPlayersProfilesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/squad/rpc/get-squad-players-profiles/${params.playerId}`,
    atomName: `squadPlayersProfilesAtom`,
  }
}
