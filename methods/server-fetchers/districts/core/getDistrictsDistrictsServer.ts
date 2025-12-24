// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TDistrictsDistricts, TDistrictsDistrictsRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/districts/districts"
import { fetchDistrictsDistricts } from "@/methods/services/districts/fetchDistrictsDistricts"

type TResult = {
  raw: TDistrictsDistricts[]
  byKey: TDistrictsDistrictsRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getDistrictsDistrictsServer(): Promise<TResult> {
  const { record } = await fetchDistrictsDistricts()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/districts/districts`,
    atomName: `districtsAtom`,
  }
}
