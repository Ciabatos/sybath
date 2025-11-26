// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCitiesByKey } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { TCitiesCitiesParams } from "@/db/postgresMainDatabase/schemas/cities/cities" 
import type { TCitiesCities, TCitiesCitiesRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"

export async function getCitiesCitiesByKeyServer( params: TCitiesCitiesParams): Promise<{
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapIdMapTileXMapTileY
  apiPath: string
}> {
  const getCitiesCitiesByKeyData = await getCitiesCitiesByKey(params)

  const data = getCitiesCitiesByKeyData ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], getCitiesCitiesByKeyData) as TCitiesCitiesRecordByMapIdMapTileXMapTileY) : {}

  return { raw: getCitiesCitiesByKeyData, byKey: data, apiPath: `/api/cities/cities/${params.id}` }
}
