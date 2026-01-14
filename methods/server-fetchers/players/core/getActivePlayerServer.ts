// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type {
  TActivePlayer,
  TActivePlayerParams,
  TActivePlayerRecordById,
} from "@/db/postgresMainDatabase/schemas/players/activePlayer"
import { fetchActivePlayerService } from "@/methods/services/players/fetchActivePlayerService"

type TResult = {
  raw: TActivePlayer[]
  byKey: TActivePlayerRecordById
  apiPath: string
  atomName: string
}

export async function getActivePlayerServer(params: TActivePlayerParams): Promise<TResult> {
  const { record } = await fetchActivePlayerService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-active-player/${params.userId}`,
    atomName: `activePlayerAtom`,
  }
}
