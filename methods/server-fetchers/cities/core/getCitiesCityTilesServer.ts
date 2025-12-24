// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { fetchCitiesCityTiles } from "@/methods/services/cities/fetchCitiesCityTiles"

type TResult = {
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
  atomName: string
}

export async function getCitiesCityTilesServer(): Promise<TResult> {
  const { record } = await fetchCitiesCityTiles()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/city-tiles`,
    atomName: `cityTilesAtom`,
  }
}
