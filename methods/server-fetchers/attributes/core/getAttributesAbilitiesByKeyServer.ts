// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesAbilitiesByKey } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities" 
import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getAttributesAbilitiesByKeyServer( params: TAttributesAbilitiesParams): Promise<{
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getAttributesAbilitiesByKeyData = await getAttributesAbilitiesByKey(params)

  const data = getAttributesAbilitiesByKeyData ? (arrayToObjectKey(["id"], getAttributesAbilitiesByKeyData) as TAttributesAbilitiesRecordById) : {}

  const result = { raw: getAttributesAbilitiesByKeyData, byKey: data, apiPath: `/api/attributes/abilities/${params.id}`, atomName: `abilitiesAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
