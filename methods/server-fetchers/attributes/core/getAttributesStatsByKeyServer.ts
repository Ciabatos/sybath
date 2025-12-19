// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesStatsByKey } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { TAttributesStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/stats" 
import type { TAttributesStats, TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getAttributesStatsByKeyServer( params: TAttributesStatsParams): Promise<{
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getAttributesStatsByKeyData = await getAttributesStatsByKey(params)

  const data = getAttributesStatsByKeyData ? (arrayToObjectKey(["id"], getAttributesStatsByKeyData) as TAttributesStatsRecordById) : {}

  const result = { raw: getAttributesStatsByKeyData, byKey: data, apiPath: `/api/attributes/stats/${params.id}`, atomName: `statsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
