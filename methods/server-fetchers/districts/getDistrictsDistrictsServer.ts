// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import type { TDistrictsDistricts, TDistrictsDistrictsRecordByMapIdMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"


export async function getDistrictsDistrictsServer(): Promise<{
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapIdMapTileXMapTileY
  apiPath: string
}> {
  const getDistrictsDistrictsData = await getDistrictsDistricts()

  const data = getDistrictsDistrictsData ? (arrayToObjectKey(["mapId", "mapTileX", "mapTileY"], getDistrictsDistrictsData) as TDistrictsDistrictsRecordByMapIdMapTileXMapTileY) : {}

  return { raw: getDistrictsDistrictsData, byKey: data, apiPath: `/api/districts/districts` }
}
