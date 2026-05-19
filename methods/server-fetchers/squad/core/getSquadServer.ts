// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TSquadParams } from "@/db/postgresMainDatabase/schemas/squad/squad"
import type { TSquadRecordBySquadId, TSquad } from "@/db/postgresMainDatabase/schemas/squad/squad"
import { fetchSquadService } from "@/methods/services/squad/fetchSquadService"

type TResult = {
  raw: TSquad[]
  byKey: TSquadRecordBySquadId
  apiPath: string
  atomName: string
}

export async function getSquadServer(params: TSquadParams, options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchSquadService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/squad/rpc/get-squad/${params.playerId}`,
    atomName: `squadAtom`,
  }
}
