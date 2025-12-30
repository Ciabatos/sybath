// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TWorldMaps, TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"
import type{ TWorldMapsParams } from "@/db/postgresMainDatabase/schemas/world/maps" 
import { fetchWorldMapsByKeyService } from "@/methods/services/world/fetchWorldMapsByKeyService"

type TResult = {
  raw: TWorldMaps[]
  byKey: TWorldMapsRecordById
  apiPath: string
  atomName: string
}

export async function getWorldMapsByKeyServer( params: TWorldMapsParams): Promise<TResult> {
  const { record } = await fetchWorldMapsByKeyService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/maps/${params.id}`,
    atomName: `mapsAtom`,
  }
}