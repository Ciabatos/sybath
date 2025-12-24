// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TDistrictsDistricts, TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import type{ TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts" 
import { fetchDistrictsDistrictsByKey } from "@/methods/services/districts/fetchDistrictsDistrictsByKey"

type TResult = {
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getDistrictsDistrictsByKeyServer( params: TDistrictsDistrictsParams): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictsByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/districts/districts/${params.mapId}`,
    atomName: `districtsAtom`,
  }
}