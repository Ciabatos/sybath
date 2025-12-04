// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import type { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"

export async function getCitiesCitiesServer(): Promise<{
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getCitiesCitiesData = await getCitiesCities()

  const data = getCitiesCitiesData ? (arrayToObjectKey(["mapTileX", "mapTileY"], getCitiesCitiesData) as TCitiesCitiesRecordByMapTileXMapTileY) : {}

  return { raw: getCitiesCitiesData, byKey: data, apiPath: `/api/cities/cities` }
}
