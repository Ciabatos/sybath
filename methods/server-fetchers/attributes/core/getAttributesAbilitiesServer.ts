// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { fetchAttributesAbilities } from "@/methods/services/attributes/fetchAttributesAbilities"

type TResult = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesAbilitiesServer(): Promise<TResult> {
  const { record } = await fetchAttributesAbilities()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/abilities`,
    atomName: `abilitiesAtom`,
  }
}
