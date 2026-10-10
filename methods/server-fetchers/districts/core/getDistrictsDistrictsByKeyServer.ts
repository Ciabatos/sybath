// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TDistrictsDistricts,
  TDistrictsDistrictsRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/districts/districts"
import type { TDistrictsDistrictsParams } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { fetchDistrictsDistrictsByKeyService } from "@/methods/services/districts/fetchDistrictsDistrictsByKeyService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getDistrictsDistrictsByKeyServer(
  params: TDistrictsDistrictsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictsByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/districts/districts/${params.mapId}`,
    atomName: `districtsAtom`,
  }
}
