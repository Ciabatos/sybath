// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCityTiles } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import type { TCitiesCityTiles, TCitiesCityTilesRecordByCityIdXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"


export async function getCitiesCityTilesServer(): Promise<{
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByCityIdXY
  apiPath: string
}> {
  const getCitiesCityTilesData = await getCitiesCityTiles()

  const data = getCitiesCityTilesData ? (arrayToObjectKey(["cityId", "x", "y"], getCitiesCityTilesData) as TCitiesCityTilesRecordByCityIdXY) : {}

  return { raw: getCitiesCityTilesData, byKey: data, apiPath: `/api/cities/city-tiles` }
}
