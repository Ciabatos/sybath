// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldTerrainTypesByKey } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { TWorldTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import type { TWorldTerrainTypes, TWorldTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

export async function getWorldTerrainTypesByKeyServer(params: TWorldTerrainTypesParams): Promise<{
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
}> {
  const getWorldTerrainTypesByKeyData = await getWorldTerrainTypesByKey(params)

  const data = getWorldTerrainTypesByKeyData ? (arrayToObjectKey(["id"], getWorldTerrainTypesByKeyData) as TWorldTerrainTypesRecordById) : {}

  return { raw: getWorldTerrainTypesByKeyData, byKey: data, apiPath: `/api/world/terrain-types/${params.id}` }
}
