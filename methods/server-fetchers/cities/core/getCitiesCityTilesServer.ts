// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { fetchCitiesCityTilesService } from "@/methods/services/cities/fetchCitiesCityTilesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getCitiesCityTilesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchCitiesCityTilesService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/cities/city-tiles`,
    atomName: `cityTilesAtom`,
  }
}
