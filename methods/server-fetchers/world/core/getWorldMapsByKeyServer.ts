// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapsByKey } from "@/db/postgresMainDatabase/schemas/world/maps"
import { TWorldMapsParams } from "@/db/postgresMainDatabase/schemas/world/maps" 
import type { TWorldMaps, TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldMapsByKeyServer( params: TWorldMapsParams): Promise<{
  raw: TWorldMaps[]
  byKey: TWorldMapsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldMapsByKeyData = await getWorldMapsByKey(params)

  const data = getWorldMapsByKeyData ? (arrayToObjectKey(["id"], getWorldMapsByKeyData) as TWorldMapsRecordById) : {}

  const result = { raw: getWorldMapsByKeyData, byKey: data, apiPath: `/api/world/maps/${params.id}`, atomName: `mapsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
