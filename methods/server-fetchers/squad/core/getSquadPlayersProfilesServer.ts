// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TSquadPlayersProfilesParams } from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import type {
  TSquadPlayersProfilesRecordByOtherPlayerId,
  TSquadPlayersProfiles,
} from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import { fetchSquadPlayersProfilesService } from "@/methods/services/squad/fetchSquadPlayersProfilesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TSquadPlayersProfiles[]
  byKey: TSquadPlayersProfilesRecordByOtherPlayerId
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getSquadPlayersProfilesServer(
  params: TSquadPlayersProfilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchSquadPlayersProfilesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/squad/rpc/get-squad-players-profiles/${params.playerId}`,
    atomName: `squadPlayersProfilesAtom`,
  }
}
