// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCities } from "@/db/postgresMainDatabase/schemas/cities/cities"
import type { TCitiesCities, TCitiesCitiesRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"


export async function getCitiesCitiesServer(): Promise<{
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapIdMapTileXMapTileY
  apiPath: string
}> {
  const getCitiesCitiesData = await getCitiesCities()

  const data = getCitiesCitiesData ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], getCitiesCitiesData) as TCitiesCitiesRecordByMapIdMapTileXMapTileY) : {}

  return { raw: getCitiesCitiesData, byKey: data, apiPath: `/api/cities/cities` }
}
