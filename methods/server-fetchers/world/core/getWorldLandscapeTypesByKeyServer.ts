// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldLandscapeTypesByKey } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldLandscapeTypesParams } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes" 
import type { TWorldLandscapeTypes, TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getWorldLandscapeTypesByKeyServer( params: TWorldLandscapeTypesParams): Promise<{
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getWorldLandscapeTypesByKeyData = await getWorldLandscapeTypesByKey(params)

  const data = getWorldLandscapeTypesByKeyData ? (arrayToObjectKey(["id"], getWorldLandscapeTypesByKeyData) as TWorldLandscapeTypesRecordById) : {}

  const result = { raw: getWorldLandscapeTypesByKeyData, byKey: data, apiPath: `/api/world/landscape-types/${params.id}`, atomName: `landscapeTypesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
