// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TMapCities, TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { getMapCitiesByKey, TMapCitiesParams } from "@/db/postgresMainDatabase/schemas/map/cities"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"

export async function getMapCitiesByKeyServer(params: TMapCitiesParams): Promise<{
  raw: TMapCities[]
  byKey: TMapCitiesRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getMapCitiesByKeyData = await getMapCitiesByKey(params)

  const data = getMapCitiesByKeyData ? (arrayToObjectKeysId("mapTileX", "mapTileY", getMapCitiesByKeyData) as TMapCitiesRecordByMapTileXMapTileY) : {}

  return { raw: getMapCitiesByKeyData, byKey: data, apiPath: `/api/map/cities/${params.id}` }
}
