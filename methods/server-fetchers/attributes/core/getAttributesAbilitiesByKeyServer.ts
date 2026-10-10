// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TAttributesAbilities,
  TAttributesAbilitiesRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import type { TAttributesAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { fetchAttributesAbilitiesByKeyService } from "@/methods/services/attributes/fetchAttributesAbilitiesByKeyService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getAttributesAbilitiesByKeyServer(
  params: TAttributesAbilitiesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchAttributesAbilitiesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/attributes/abilities/${params.id}`,
    atomName: `abilitiesAtom`,
  }
}
