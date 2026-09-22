// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TDefaultActivePlayerParams } from "@/db/postgresMainDatabase/schemas/players/defaultActivePlayer"
import type {
  TDefaultActivePlayerRecordById,
  TDefaultActivePlayer,
} from "@/db/postgresMainDatabase/schemas/players/defaultActivePlayer"
import { fetchDefaultActivePlayerService } from "@/methods/services/players/fetchDefaultActivePlayerService"

type TResult = {
  raw: TDefaultActivePlayer[]
  byKey: TDefaultActivePlayerRecordById
  apiPath: string
  atomName: string
}

export async function getDefaultActivePlayerServer(
  params: TDefaultActivePlayerParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchDefaultActivePlayerService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/players/rpc/get-default-active-player`,
    atomName: `defaultActivePlayerAtom`,
  }
}
