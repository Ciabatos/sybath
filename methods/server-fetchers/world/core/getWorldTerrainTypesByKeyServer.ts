// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TWorldTerrainTypes,
  TWorldTerrainTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import type { TWorldTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { fetchWorldTerrainTypesByKeyService } from "@/methods/services/world/fetchWorldTerrainTypesByKeyService"

type TResult = {
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: string
}

export async function getWorldTerrainTypesByKeyServer(
  params: TWorldTerrainTypesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchWorldTerrainTypesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/terrain-types/${params.id}`,
    atomName: `terrainTypesAtom`,
  }
}
