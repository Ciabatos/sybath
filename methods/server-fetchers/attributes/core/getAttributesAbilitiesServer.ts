// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getAttributesAbilitiesServer(): Promise<{
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getAttributesAbilitiesData = await getAttributesAbilities()

  const data = getAttributesAbilitiesData ? (arrayToObjectKey(["id"], getAttributesAbilitiesData) as TAttributesAbilitiesRecordById) : {}

  const result = { raw: getAttributesAbilitiesData, byKey: data, apiPath: `/api/attributes/abilities`, atomName: `abilitiesAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
