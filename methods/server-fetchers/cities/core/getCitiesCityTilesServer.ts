// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getCitiesCityTiles } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"

export async function getCitiesCityTilesServer(): Promise<{
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
}> {
  const getCitiesCityTilesData = await getCitiesCityTiles()

  const data = getCitiesCityTilesData
    ? (arrayToObjectKey(["x", "y"], getCitiesCityTilesData) as TCitiesCityTilesRecordByXY)
    : {}

  return { raw: getCitiesCityTilesData, byKey: data, apiPath: `/api/cities/city-tiles` }
}
