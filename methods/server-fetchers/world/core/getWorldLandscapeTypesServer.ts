// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import type { TWorldLandscapeTypes, TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldLandscapeTypesServer(): Promise<{
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldLandscapeTypesData = await getWorldLandscapeTypes()

  const data = getWorldLandscapeTypesData ? (arrayToObjectKey(["id"], getWorldLandscapeTypesData) as TWorldLandscapeTypesRecordById) : {}

  const result = { raw: getWorldLandscapeTypesData, byKey: data, apiPath: `/api/world/landscape-types`, atomName: `landscapeTypesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
