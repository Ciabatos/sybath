// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TWorldMaps, TWorldMapsRecordById } from "@/db/postgresMainDatabase/schemas/world/maps"
import { fetchWorldMapsService } from "@/methods/services/world/fetchWorldMapsService"

type TResult = {
  raw: TWorldMaps[]
  byKey: TWorldMapsRecordById
  apiPath: string
  atomName: string
}

export async function getWorldMapsServer(): Promise<TResult> {
  const { record } = await fetchWorldMapsService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/world/maps`,
    atomName: `mapsAtom`,
  }
}
