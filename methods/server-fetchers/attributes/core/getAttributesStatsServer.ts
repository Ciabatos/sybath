// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TAttributesStats, TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { fetchAttributesStatsService } from "@/methods/services/attributes/fetchAttributesStatsService"

type TResult = {
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesStatsServer(): Promise<TResult> {
  const { record } = await fetchAttributesStatsService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/stats`,
    atomName: `statsAtom`,
  }
}
