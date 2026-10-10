// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TCitiesCities,
  TCitiesCitiesRecordByMapTileXMapTileY,
} from "@/db/postgresMainDatabase/schemas/cities/cities"
import type { TCitiesCitiesParams } from "@/db/postgresMainDatabase/schemas/cities/cities"
import { fetchCitiesCitiesByKeyService } from "@/methods/services/cities/fetchCitiesCitiesByKeyService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TCitiesCities[]
  byKey: TCitiesCitiesRecordByMapTileXMapTileY
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getCitiesCitiesByKeyServer(
  params: TCitiesCitiesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchCitiesCitiesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/cities/cities/${params.mapId}`,
    atomName: `citiesAtom`,
  }
}
