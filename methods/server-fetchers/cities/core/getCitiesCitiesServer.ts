// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { fetchCitiesCities } from "@/methods/services/cities/fetchCitiesCities"

type TResult = {
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getCitiesCitiesServer(): Promise<TResult> {
  const { record } = await fetchCitiesCities()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/cities`,
    atomName: `citiesAtom`,
  }
}
