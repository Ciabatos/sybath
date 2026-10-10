// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TAttributesAbilities,
  TAttributesAbilitiesRecordById,
} from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { fetchAttributesAbilitiesService } from "@/methods/services/attributes/fetchAttributesAbilitiesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getAttributesAbilitiesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchAttributesAbilitiesService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/attributes/abilities`,
    atomName: `abilitiesAtom`,
  }
}
