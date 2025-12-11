// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesAbilities } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import type {
  TAttributesAbilities,
  TAttributesAbilitiesRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"

export async function getAttributesAbilitiesServer(): Promise<{
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
}> {
  const getAttributesAbilitiesData = await getAttributesAbilities()

  const data = getAttributesAbilitiesData
    ? (arrayToObjectKey(["id"], getAttributesAbilitiesData) as TAttributesAbilitiesRecordById)
    : {}

  return { raw: getAttributesAbilitiesData, byKey: data, apiPath: `/api/attributes/abilities` }
}
