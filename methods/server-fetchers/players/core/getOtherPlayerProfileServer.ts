// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TOtherPlayerProfileParams } from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import type {
  TOtherPlayerProfileRecordByName,
  TOtherPlayerProfile,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import { fetchOtherPlayerProfileService } from "@/methods/services/players/fetchOtherPlayerProfileService"

type TResult = {
  raw: TOtherPlayerProfile[]
  byKey: TOtherPlayerProfileRecordByName
  apiPath: string
  atomName: string
}

export async function getOtherPlayerProfileServer(
  params: TOtherPlayerProfileParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchOtherPlayerProfileService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-other-player-profile/${params.playerId}/${params.otherPlayerMaskId}`,
    atomName: `otherPlayerProfileAtom`,
  }
}
