// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesStats, TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import type{ TAttributesStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/stats" 
import { fetchAttributesStatsByKeyService } from "@/methods/services/attributes/fetchAttributesStatsByKeyService"

type TResult = {
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesStatsByKeyServer( params: TAttributesStatsParams): Promise<TResult> {
  const { record } = await fetchAttributesStatsByKeyService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/stats/${params.id}`,
    atomName: `statsAtom`,
  }
}