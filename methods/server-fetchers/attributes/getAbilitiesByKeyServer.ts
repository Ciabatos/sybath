// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getAttributesAbilitiesByKey, TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getAttributesAbilitiesByKeyServer(params: TAttributesAbilitiesParams): Promise<{
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
}> {
  const getAttributesAbilitiesByKeyData = await getAttributesAbilitiesByKey(params)

  const data = getAttributesAbilitiesByKeyData ? (arrayToObjectKeyId("id", getAttributesAbilitiesByKeyData) as TAttributesAbilitiesRecordById) : {}

  return { raw: getAttributesAbilitiesByKeyData, byKey: data, apiPath: `/api/attributes/abilities/${params.id}` }
}
