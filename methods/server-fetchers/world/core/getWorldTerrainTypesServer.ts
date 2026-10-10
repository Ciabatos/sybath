// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TWorldTerrainTypes,
  TWorldTerrainTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { fetchWorldTerrainTypesService } from "@/methods/services/world/fetchWorldTerrainTypesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getWorldTerrainTypesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchWorldTerrainTypesService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/world/terrain-types`,
    atomName: `terrainTypesAtom`,
  }
}
