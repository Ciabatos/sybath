// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldMapTiles } from "@/db/postgresMainDatabase/schemas/world/mapTiles"
import type { TWorldMapTiles, TWorldMapTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/world/mapTiles"

export async function getWorldMapTilesServer(): Promise<{
  raw: TWorldMapTiles[]
  byKey: TWorldMapTilesRecordByXY
  apiPath: string
}> {
  const getWorldMapTilesData = await getWorldMapTiles()

  const data = getWorldMapTilesData
    ? (arrayToObjectKey(["x", "y"], getWorldMapTilesData) as TWorldMapTilesRecordByXY)
    : {}

  return { raw: getWorldMapTilesData, byKey: data, apiPath: `/api/world/map-tiles` }
}
