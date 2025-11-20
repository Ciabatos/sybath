// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TMapMapTiles, TMapMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { getMapMapTiles } from "@/db/postgresMainDatabase/schemas/map/mapTiles"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"

export async function getMapMapTilesServer(): Promise<{
  raw: TMapMapTiles[]
  byKey: TMapMapTilesRecordByXY
  apiPath: string
}> {
  const getMapMapTilesData = await getMapMapTiles()

  const data = getMapMapTilesData ? (arrayToObjectKeysId("x", "y", getMapMapTilesData) as TMapMapTilesRecordByXY) : {}

  return { raw: getMapMapTilesData, byKey: data, apiPath: `/api/map/map-tiles` }
}
