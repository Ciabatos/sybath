// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TWorldLandscapeTypes,
  TWorldLandscapeTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import type { TWorldLandscapeTypesParams } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { fetchWorldLandscapeTypesByKeyService } from "@/methods/services/world/fetchWorldLandscapeTypesByKeyService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getWorldLandscapeTypesByKeyServer(
  params: TWorldLandscapeTypesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchWorldLandscapeTypesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/landscape-types/${params.id}`,
    atomName: `landscapeTypesAtom`,
  }
}
