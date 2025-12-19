// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldTerrainTypesByKey } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TWorldTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/world/terrainTypes" 
import type { TWorldTerrainTypes, TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldTerrainTypesByKeyServer( params: TWorldTerrainTypesParams): Promise<{
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldTerrainTypesByKeyData = await getWorldTerrainTypesByKey(params)

  const data = getWorldTerrainTypesByKeyData ? (arrayToObjectKey(["id"], getWorldTerrainTypesByKeyData) as TWorldTerrainTypesRecordById) : {}

  const result = { raw: getWorldTerrainTypesByKeyData, byKey: data, apiPath: `/api/world/terrain-types/${params.id}`, atomName: `terrainTypesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
