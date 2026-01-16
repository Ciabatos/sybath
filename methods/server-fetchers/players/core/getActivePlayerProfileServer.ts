// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TActivePlayerProfileParams } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile" 
import type { TActivePlayerProfileRecordByName,TActivePlayerProfile } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { fetchActivePlayerProfileService } from "@/methods/services/players/fetchActivePlayerProfileService"

type TResult = {
  raw: TActivePlayerProfile[]
  byKey: TActivePlayerProfileRecordByName
  apiPath: string
  atomName: string
}

export async function getActivePlayerProfileServer( params: TActivePlayerProfileParams): Promise<TResult> {
  const { record } = await fetchActivePlayerProfileService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-active-player-profile/${params.playerId}`,
    atomName: `activePlayerProfileAtom`,
  }
}

