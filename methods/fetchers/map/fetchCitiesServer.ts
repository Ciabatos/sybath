// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TMapCities, TMapCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/cities"
import { getMapCities } from "@/db/postgresMainDatabase/schemas/map/cities"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"

export async function getMapCitiesServer(): Promise<{
  raw: TMapCities[]
  byKey: TMapCitiesRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getMapCitiesData = await getMapCities()

  const data = getMapCitiesData ? (arrayToObjectKeysId("mapTileX", "mapTileY", getMapCitiesData) as TMapCitiesRecordByMapTileXMapTileY) : {}

  return { raw: getMapCitiesData, byKey: data, apiPath: `/api/map/cities` }
}
