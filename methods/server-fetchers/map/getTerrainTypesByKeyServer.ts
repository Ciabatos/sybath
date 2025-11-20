// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TMapTerrainTypes, TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { getMapTerrainTypesByKey, TMapTerrainTypesParams } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getMapTerrainTypesByKeyServer(params: TMapTerrainTypesParams): Promise<{
  raw: TMapTerrainTypes[]
  byKey: TMapTerrainTypesRecordById
  apiPath: string
}> {
  const getMapTerrainTypesByKeyData = await getMapTerrainTypesByKey(params)

  const data = getMapTerrainTypesByKeyData ? (arrayToObjectKeyId("id", getMapTerrainTypesByKeyData) as TMapTerrainTypesRecordById) : {}

  return { raw: getMapTerrainTypesByKeyData, byKey: data, apiPath: `/api/map/terrain-types/${params.id}` }
}
