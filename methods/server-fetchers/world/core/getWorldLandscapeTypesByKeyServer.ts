// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldLandscapeTypes, TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import type{ TWorldLandscapeTypesParams } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes" 
import { fetchWorldLandscapeTypesByKey } from "@/methods/services/world/fetchWorldLandscapeTypesByKey"

type TResult = {
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: string
}

export async function getWorldLandscapeTypesByKeyServer( params: TWorldLandscapeTypesParams): Promise<TResult> {
  const { record } = await fetchWorldLandscapeTypesByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/landscape-types/${params.id}`,
    atomName: `landscapeTypesAtom`,
  }
}