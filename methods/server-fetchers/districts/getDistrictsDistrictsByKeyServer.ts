// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictsByKey } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts" 
import type { TDistrictsDistricts, TDistrictsDistrictsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"

export async function getDistrictsDistrictsByKeyServer( params: TDistrictsDistrictsParams): Promise<{
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapIdMapTileXMapTileY
  apiPath: string
}> {
  const getDistrictsDistrictsByKeyData = await getDistrictsDistrictsByKey(params)

  const data = getDistrictsDistrictsByKeyData ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], getDistrictsDistrictsByKeyData) as TDistrictsDistrictsRecordByMapIdMapTileXMapTileY) : {}

  return { raw: getDistrictsDistrictsByKeyData, byKey: data, apiPath: `/api/districts/districts/${params.id}` }
}
