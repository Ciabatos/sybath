// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getAttributesAbilitiesByKey } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import type {
  TAttributesAbilities,
  TAttributesAbilitiesRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"

export async function getAttributesAbilitiesByKeyServer(params: TAttributesAbilitiesParams): Promise<{
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: string
}> {
  const getAttributesAbilitiesByKeyData = await getAttributesAbilitiesByKey(params)

  const data = getAttributesAbilitiesByKeyData
    ? (arrayToObjectKey(["id"], getAttributesAbilitiesByKeyData) as TAttributesAbilitiesRecordById)
    : {}

  return {
    raw: getAttributesAbilitiesByKeyData,
    byKey: data,
    apiPath: `/api/attributes/abilities/${params.id}`,
    atomName: `abilitiesAtom`,
  }
}
