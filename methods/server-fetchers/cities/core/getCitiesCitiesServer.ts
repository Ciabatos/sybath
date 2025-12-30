// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { fetchCitiesCitiesService } from "@/methods/services/cities/fetchCitiesCitiesService"

type TResult = {
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getCitiesCitiesServer(): Promise<TResult> {
  const { record } = await fetchCitiesCitiesService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/cities`,
    atomName: `citiesAtom`,
  }
}
