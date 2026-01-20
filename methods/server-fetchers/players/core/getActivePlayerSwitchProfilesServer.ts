// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TActivePlayerSwitchProfilesParams } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles" 
import type { TActivePlayerSwitchProfilesRecordByName,TActivePlayerSwitchProfiles } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { fetchActivePlayerSwitchProfilesService } from "@/methods/services/players/fetchActivePlayerSwitchProfilesService"

type TResult = {
  raw: TActivePlayerSwitchProfiles[]
  byKey: TActivePlayerSwitchProfilesRecordByName
  apiPath: string
  atomName: string
}

export async function getActivePlayerSwitchProfilesServer( params: TActivePlayerSwitchProfilesParams): Promise<TResult> {
  const { record } = await fetchActivePlayerSwitchProfilesService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`,
    atomName: `activePlayerSwitchProfilesAtom`,
  }
}

