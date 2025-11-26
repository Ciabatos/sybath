// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldLandscapeTypesByKey } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { TWorldLandscapeTypesParams } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes" 
import type { TWorldLandscapeTypes, TWorldLandscapeTypesRecordById } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"

export async function getWorldLandscapeTypesByKeyServer( params: TWorldLandscapeTypesParams): Promise<{
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
}> {
  const getWorldLandscapeTypesByKeyData = await getWorldLandscapeTypesByKey(params)

  const data = getWorldLandscapeTypesByKeyData ? (arrayToObjectKey(["id"], getWorldLandscapeTypesByKeyData) as TWorldLandscapeTypesRecordById) : {}

  return { raw: getWorldLandscapeTypesByKeyData, byKey: data, apiPath: `/api/world/landscape-types/${params.id}` }
}
