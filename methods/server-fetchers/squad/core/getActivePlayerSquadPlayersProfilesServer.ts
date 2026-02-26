// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TActivePlayerSquadPlayersProfilesParams } from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquadPlayersProfiles"
import type {
  TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId,
  TActivePlayerSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquadPlayersProfiles"
import { fetchActivePlayerSquadPlayersProfilesService } from "@/methods/services/squad/fetchActivePlayerSquadPlayersProfilesService"

type TResult = {
  raw: TActivePlayerSquadPlayersProfiles[]
  byKey: TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

export async function getActivePlayerSquadPlayersProfilesServer(
  params: TActivePlayerSquadPlayersProfilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchActivePlayerSquadPlayersProfilesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/squad/rpc/get-active-player-squad-players-profiles/${params.playerId}`,
    atomName: `activePlayerSquadPlayersProfilesAtom`,
  }
}
