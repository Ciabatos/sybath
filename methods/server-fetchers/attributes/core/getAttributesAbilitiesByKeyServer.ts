// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import type{ TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities" 
import { fetchAttributesAbilitiesByKey } from "@/methods/services/attributes/fetchAttributesAbilitiesByKey"

type TResult = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesAbilitiesByKeyServer( params: TAttributesAbilitiesParams): Promise<TResult> {
  const { record } = await fetchAttributesAbilitiesByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/abilities/${params.id}`,
    atomName: `abilitiesAtom`,
  }
}