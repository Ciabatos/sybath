// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapsByKey } from "@/db/postgresMainDatabase/schemas/world/maps"
import { TWorldMapsParams } from "@/db/postgresMainDatabase/schemas/world/maps"
import type { TWorldMaps, TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"

export async function getWorldMapsByKeyServer(params: TWorldMapsParams): Promise<{
  raw: TWorldMaps[]
  byKey: TWorldMapsRecordById
  apiPath: string
}> {
  const getWorldMapsByKeyData = await getWorldMapsByKey(params)

  const data = getWorldMapsByKeyData ? (arrayToObjectKey(["id"], getWorldMapsByKeyData) as TWorldMapsRecordById) : {}

  return { raw: getWorldMapsByKeyData, byKey: data, apiPath: `/api/world/maps/${params.id}` }
}
