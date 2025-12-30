// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TCitiesCities, TCitiesCitiesRecordByMapTileXMapTileY } from "@/db/postgresMainDatabase/schemas/cities/cities"
import type{ TCitiesCitiesParams } from "@/db/postgresMainDatabase/schemas/cities/cities" 
import { fetchCitiesCitiesByKeyService } from "@/methods/services/cities/fetchCitiesCitiesByKeyService"

type TResult = {
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
  atomName: string
}

export async function getCitiesCitiesByKeyServer( params: TCitiesCitiesParams): Promise<TResult> {
  const { record } = await fetchCitiesCitiesByKeyService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/cities/${params.mapId}`,
    atomName: `citiesAtom`,
  }
}