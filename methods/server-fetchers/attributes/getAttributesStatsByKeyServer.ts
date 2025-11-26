// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesStatsByKey } from "@/db/postgresMainDatabase/schemas/attributes/stats"
import { TAttributesStatsParams } from "@/db/postgresMainDatabase/schemas/attributes/stats" 
import type { TAttributesStats, TAttributesStatsRecordById } from "@/db/postgresMainDatabase/schemas/attributes/stats"

export async function getAttributesStatsByKeyServer( params: TAttributesStatsParams): Promise<{
  raw: TAttributesStats[]
  byKey: TAttributesStatsRecordById
  apiPath: string
}> {
  const getAttributesStatsByKeyData = await getAttributesStatsByKey(params)

  const data = getAttributesStatsByKeyData ? (arrayToObjectKey(["id"], getAttributesStatsByKeyData) as TAttributesStatsRecordById) : {}

  return { raw: getAttributesStatsByKeyData, byKey: data, apiPath: `/api/attributes/stats/${params.id}` }
}
