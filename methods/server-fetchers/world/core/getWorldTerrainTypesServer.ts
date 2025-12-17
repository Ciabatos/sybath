// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import type {
  TWorldTerrainTypes,
  TWorldTerrainTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/terrainTypes"

export async function getWorldTerrainTypesServer(): Promise<{
  raw: TWorldTerrainTypes[]
  byKey: TWorldTerrainTypesRecordById
  apiPath: string
  atomName: string
}> {
  const getWorldTerrainTypesData = await getWorldTerrainTypes()

  const data = getWorldTerrainTypesData
    ? (arrayToObjectKey(["id"], getWorldTerrainTypesData) as TWorldTerrainTypesRecordById)
    : {}

  return {
    raw: getWorldTerrainTypesData,
    byKey: data,
    apiPath: `/api/world/terrain-types`,
    atomName: `terrainTypesAtom`,
  }
}
