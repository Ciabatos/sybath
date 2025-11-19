// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TMapDistricts, TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { getMapDistricts } from "@/db/postgresMainDatabase/schemas/map/districts"
import { arrayToObjectKeysId } from "@/methods/functions/util/converters"

export async function getMapDistrictsServer(): Promise<{
  raw: TMapDistricts[]
  byKey: TMapDistrictsRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getMapDistrictsData = await getMapDistricts()

  const data = getMapDistrictsData ? (arrayToObjectKeysId("mapTileX", "mapTileY", getMapDistrictsData) as TMapDistrictsRecordByMapTileXMapTileY) : {}

  return { raw: getMapDistrictsData, byKey: data, apiPath: `/api/map/districts` }
}
