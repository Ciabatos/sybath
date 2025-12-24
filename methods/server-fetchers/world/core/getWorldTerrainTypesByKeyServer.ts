// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldTerrainTypes, TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import type{ TWorldTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/world/terrainTypes" 
import { fetchWorldTerrainTypesByKey } from "@/methods/services/world/fetchWorldTerrainTypesByKey"

type TResult = {
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: string
}

export async function getWorldTerrainTypesByKeyServer( params: TWorldTerrainTypesParams): Promise<TResult> {
  const { record } = await fetchWorldTerrainTypesByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/terrain-types/${params.id}`,
    atomName: `terrainTypesAtom`,
  }
}