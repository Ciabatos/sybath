// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TMapLandscapeTypes, TMapLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { getMapLandscapeTypes } from "@/db/postgresMainDatabase/schemas/map/landscapeTypes"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"

export async function getMapLandscapeTypesServer(): Promise<{
  raw: TMapLandscapeTypes[]
  byKey: TMapLandscapeTypesRecordById
  apiPath: string
}> {
  const getMapLandscapeTypesData = await getMapLandscapeTypes()

  const data = getMapLandscapeTypesData ? (arrayToObjectKeyId("id", getMapLandscapeTypesData) as TMapLandscapeTypesRecordById) : {}

  return { raw: getMapLandscapeTypesData, byKey: data, apiPath: `/api/map/landscape-types` }
}
