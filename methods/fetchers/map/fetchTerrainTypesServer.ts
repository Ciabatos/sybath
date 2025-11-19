// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TMapTerrainTypes, TMapTerrainTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { getMapTerrainTypes } from "@/db/postgresMainDatabase/schemas/map/terrainTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getMapTerrainTypesServer(): Promise<{
  raw: TMapTerrainTypes[]
  byKey: TMapTerrainTypesRecordById
  apiPath: string
}> {
  const getMapTerrainTypesData = await getMapTerrainTypes()

  const data = getMapTerrainTypesData ? (arrayToObjectKeyId("id", getMapTerrainTypesData) as TMapTerrainTypesRecordById) : {}

  return { raw: getMapTerrainTypesData, byKey: data, apiPath: `/api/map/terrain-types` }
}
