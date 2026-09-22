// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherSquadPlayersProfilesParams } from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import type {
  TOtherSquadPlayersProfilesRecordByOtherPlayerId,
  TOtherSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { fetchOtherSquadPlayersProfilesService } from "@/methods/services/squad/fetchOtherSquadPlayersProfilesService"

type TResult = {
  raw: TOtherSquadPlayersProfiles[]
  byKey: TOtherSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: string
}

export async function getOtherSquadPlayersProfilesServer(
  params: TOtherSquadPlayersProfilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherSquadPlayersProfilesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/squad/rpc/get-other-squad-players-profiles/${params.playerId}/${params.squadId}`,
    atomName: `otherSquadPlayersProfilesAtom`,
  }
}
