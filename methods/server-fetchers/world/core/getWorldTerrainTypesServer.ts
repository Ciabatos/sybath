// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import type { TWorldTerrainTypes, TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldTerrainTypesServer(): Promise<{
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldTerrainTypesData = await getWorldTerrainTypes()

  const data = getWorldTerrainTypesData ? (arrayToObjectKey(["id"], getWorldTerrainTypesData) as TWorldTerrainTypesRecordById) : {}

  const result = { raw: getWorldTerrainTypesData, byKey: data, apiPath: `/api/world/terrain-types`, atomName: `terrainTypesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
