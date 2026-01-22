// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TCitiesCityTiles, TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import type{ TCitiesCityTilesParams } from "@/db/postgresMainDatabase/schemas/cities/cityTiles" 
import { fetchCitiesCityTilesByKeyService } from "@/methods/services/cities/fetchCitiesCityTilesByKeyService"

type TResult = {
  raw: TCitiesCityTiles[]
  byKey: TCitiesCityTilesRecordByXY
  apiPath: string
  atomName: string
}

export async function getCitiesCityTilesByKeyServer( params: TCitiesCityTilesParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchCitiesCityTilesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/cities/city-tiles/${params.cityId}`,
    atomName: `cityTilesAtom`,
  }
}