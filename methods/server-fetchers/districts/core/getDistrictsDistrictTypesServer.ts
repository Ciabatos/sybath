// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TDistrictsDistrictTypes,
  TDistrictsDistrictTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { fetchDistrictsDistrictTypesService } from "@/methods/services/districts/fetchDistrictsDistrictTypesService"

type TResult = {
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}

export async function getDistrictsDistrictTypesServer(): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictTypesService()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/districts/district-types`,
    atomName: `districtTypesAtom`,
  }
}
