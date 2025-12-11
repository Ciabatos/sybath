// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesStats } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import type { TAttributesStats, TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"

export async function getAttributesStatsServer(): Promise<{
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  apiPath: string
}> {
  const getAttributesStatsData = await getAttributesStats()

  const data = getAttributesStatsData
    ? (arrayToObjectKey(["id"], getAttributesStatsData) as TAttributesStatsRecordById)
    : {}

  return { raw: getAttributesStatsData, byKey: data, apiPath: `/api/attributes/stats` }
}
