// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TDistrictsDistricts,
  TDistrictsDistrictsRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/districts/districts"
import { fetchDistrictsDistrictsService } from "@/methods/services/districts/fetchDistrictsDistrictsService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getDistrictsDistrictsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictsService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/districts/districts`,
    atomName: `districtsAtom`,
  }
}
