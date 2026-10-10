// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TWorldLandscapeTypes,
  TWorldLandscapeTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { fetchWorldLandscapeTypesService } from "@/methods/services/world/fetchWorldLandscapeTypesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getWorldLandscapeTypesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchWorldLandscapeTypesService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/landscape-types`,
    atomName: `landscapeTypesAtom`,
  }
}
