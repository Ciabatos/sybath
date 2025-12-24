// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TWorldLandscapeTypes, TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { fetchWorldLandscapeTypes } from "@/methods/services/world/fetchWorldLandscapeTypes"

type TResult = {
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: string
}

export async function getWorldLandscapeTypesServer(): Promise<TResult> {
  const { record } = await fetchWorldLandscapeTypes()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/landscape-types`,
    atomName: `landscapeTypesAtom`,
  }
}
