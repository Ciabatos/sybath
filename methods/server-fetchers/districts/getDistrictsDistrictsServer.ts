// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistricts } from "@/db/postgresMainDatabase/schemas/districts/districts"
import type { TDistrictsDistricts, TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"


export async function getDistrictsDistrictsServer(): Promise<{
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
}> {
  const getDistrictsDistrictsData = await getDistrictsDistricts()

  const data = getDistrictsDistrictsData ? (arrayToObjectKey(["mapTileX", "mapTileY"], getDistrictsDistrictsData) as TDistrictsDistrictsRecordByMapTileXMapTileY) : {}

  return { raw: getDistrictsDistrictsData, byKey: data, apiPath: `/api/districts/districts` }
}
