// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type {
  TActivePlayerProfile,
  TActivePlayerProfileParams,
  TActivePlayerProfileRecordByName,
} from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { fetchActivePlayerProfileService } from "@/methods/services/players/fetchActivePlayerProfileService"

type TResult = {
  raw: TActivePlayerProfile[]
  byKey: TActivePlayerProfileRecordByName
  apiPath: string
  atomName: string
}

export async function getActivePlayerProfileServer(
  params: TActivePlayerProfileParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchActivePlayerProfileService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-active-player-profile/${params.playerId}`,
    atomName: `activePlayerProfileAtom`,
  }
}
