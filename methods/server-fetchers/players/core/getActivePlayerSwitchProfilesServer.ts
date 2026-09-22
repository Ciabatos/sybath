// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TActivePlayerSwitchProfilesParams } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import type {
  TActivePlayerSwitchProfilesRecordById,
  TActivePlayerSwitchProfiles,
} from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { fetchActivePlayerSwitchProfilesService } from "@/methods/services/players/fetchActivePlayerSwitchProfilesService"

type TResult = {
  raw: TActivePlayerSwitchProfiles[]
  byKey: TActivePlayerSwitchProfilesRecordById
  apiPath: string
  atomName: string
}

export async function getActivePlayerSwitchProfilesServer(
  params: TActivePlayerSwitchProfilesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchActivePlayerSwitchProfilesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`,
    atomName: `activePlayerSwitchProfilesAtom`,
  }
}
