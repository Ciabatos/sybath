// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { fetchCitiesCityTilesService } from "@/methods/services/cities/fetchCitiesCityTilesService"

type TResult = {
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
  atomName: string
}

export async function getCitiesCityTilesServer(): Promise<TResult> {
  const { record } = await fetchCitiesCityTilesService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/city-tiles`,
    atomName: `cityTilesAtom`,
  }
}
