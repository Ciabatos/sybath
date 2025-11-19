// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TMapLandscapeTypes, TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { getMapLandscapeTypesByKey, TMapLandscapeTypesParams } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getMapLandscapeTypesByKeyServer(params: TMapLandscapeTypesParams): Promise<{
  raw: TMapLandscapeTypes[]
  byKey: TMapLandscapeTypesRecordById
  apiPath: string
}> {
  const getMapLandscapeTypesByKeyData = await getMapLandscapeTypesByKey(params)

  const data = getMapLandscapeTypesByKeyData ? (arrayToObjectKeyId("id", getMapLandscapeTypesByKeyData) as TMapLandscapeTypesRecordById) : {}

  return { raw: getMapLandscapeTypesByKeyData, byKey: data, apiPath: `/api/map/landscape-types/${params.id}` }
}
