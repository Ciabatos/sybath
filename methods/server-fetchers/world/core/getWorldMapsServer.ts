// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMaps } from "@/db/postgresMainDatabase/schemas/world/maps"
import type { TWorldMaps, TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"

export async function getWorldMapsServer(): Promise<{
  raw: TWorldMaps[]
  byKey: TWorldMapsRecordById
  apiPath: string
}> {
  const getWorldMapsData = await getWorldMaps()

  const data = getWorldMapsData ? (arrayToObjectKey(["id"], getWorldMapsData) as TWorldMapsRecordById) : {}

  return { raw: getWorldMapsData, byKey: data, apiPath: `/api/world/maps` }
}
