// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { getAttributesAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getAttributesAbilitiesServer(): Promise<{
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
}> {
  const getAttributesAbilitiesData = await getAttributesAbilities()

  const data = getAttributesAbilitiesData ? (arrayToObjectKeyId("id", getAttributesAbilitiesData) as TAttributesAbilitiesRecordById) : {}

  return { raw: getAttributesAbilitiesData, byKey: data, apiPath: `/api/attributes/abilities` }
}
