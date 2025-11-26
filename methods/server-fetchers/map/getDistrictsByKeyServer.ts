// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TMapDistricts, TMapDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/map/districts"
import { getMapDistrictsByKey, TMapDistrictsParams } from "@/db/postgresMainDatabase/schemas/map/districts"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export async function getMapDistrictsByKeyServer(params: TMapDistrictsParams): Promise<{
  raw: TMapDistricts[]
  byKey: TMapDistrictsRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getMapDistrictsByKeyData = await getMapDistrictsByKey(params)

  const data = getMapDistrictsByKeyData ? (arrayToObjectKey("mapTileX", "mapTileY", getMapDistrictsByKeyData) as TMapDistrictsRecordByMapTileXMapTileY) : {}

  return { raw: getMapDistrictsByKeyData, byKey: data, apiPath: `/api/map/districts/${params.id}` }
}
