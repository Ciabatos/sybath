// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TAttributesAbilities, TAttributesAbilitiesRecordById } from "@/db/postgresMainDatabase/schemas/attributes/abilities"
import { fetchAttributesAbilitiesService } from "@/methods/services/attributes/fetchAttributesAbilitiesService"

type TResult = {
  raw: TAttributesAbilities[]
  byKey: TAttributesAbilitiesRecordById
  apiPath: string
  atomName: string
}

export async function getAttributesAbilitiesServer(): Promise<TResult> {
  const { record } = await fetchAttributesAbilitiesService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/abilities`,
    atomName: `abilitiesAtom`,
  }
}
