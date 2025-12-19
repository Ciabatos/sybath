// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMaps } from "@/db/postgresMainDatabase/schemas/world/maps"
import type { TWorldMaps, TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldMapsServer(): Promise<{
  raw: TWorldMaps[]
  byKey: TWorldMapsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldMapsData = await getWorldMaps()

  const data = getWorldMapsData ? (arrayToObjectKey(["id"], getWorldMapsData) as TWorldMapsRecordById) : {}

  const result = { raw: getWorldMapsData, byKey: data, apiPath: `/api/world/maps`, atomName: `mapsAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
