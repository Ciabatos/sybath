// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesStats } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import type { TAttributesStats, TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getAttributesStatsServer(): Promise<{
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getAttributesStatsData = await getAttributesStats()

  const data = getAttributesStatsData ? (arrayToObjectKey(["id"], getAttributesStatsData) as TAttributesStatsRecordById) : {}

  const result = { raw: getAttributesStatsData, byKey: data, apiPath: `/api/attributes/stats`, atomName: `statsAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
