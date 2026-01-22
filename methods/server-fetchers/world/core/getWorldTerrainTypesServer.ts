// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TWorldTerrainTypes, TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { fetchWorldTerrainTypesService } from "@/methods/services/world/fetchWorldTerrainTypesService"

type TResult = {
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: string
}

export async function getWorldTerrainTypesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchWorldTerrainTypesService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/terrain-types`,
    atomName: `terrainTypesAtom`,
  }
}
