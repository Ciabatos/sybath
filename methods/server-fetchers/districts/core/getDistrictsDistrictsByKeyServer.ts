// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictsByKey } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts"
import type {
  TDistrictsDistricts,
  TDistrictsDistrictsRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/districts/districts"

export async function getDistrictsDistrictsByKeyServer(params: TDistrictsDistrictsParams): Promise<{
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getDistrictsDistrictsByKeyData = await getDistrictsDistrictsByKey(params)

  const data = getDistrictsDistrictsByKeyData
    ? (arrayToObjectKey(
        ["mapTileX", "mapTileY"],
        getDistrictsDistrictsByKeyData,
      ) as TDistrictsDistrictsRecordByMapTileXMapTileY)
    : {}

  return { raw: getDistrictsDistrictsByKeyData, byKey: data, apiPath: `/api/districts/districts/${params.mapId}` }
}
