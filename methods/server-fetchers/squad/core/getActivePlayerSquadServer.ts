// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TActivePlayerSquadParams } from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquad"
import type {
  TActivePlayerSquadRecordBySquadId,
  TActivePlayerSquad,
} from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquad"
import { fetchActivePlayerSquadService } from "@/methods/services/squad/fetchActivePlayerSquadService"

type TResult = {
  raw: TActivePlayerSquad[]
  byKey: TActivePlayerSquadRecordBySquadId
  apiPath: string
  atomName: string
}

export async function getActivePlayerSquadServer(
  params: TActivePlayerSquadParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchActivePlayerSquadService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/squad/rpc/get-active-player-squad/${params.playerId}`,
    atomName: `activePlayerSquadAtom`,
  }
}
