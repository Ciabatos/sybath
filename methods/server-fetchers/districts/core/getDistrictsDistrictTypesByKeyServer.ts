// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TDistrictsDistrictTypes, TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import type{ TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes" 
import { fetchDistrictsDistrictTypesByKey } from "@/methods/services/districts/fetchDistrictsDistrictTypesByKey"

type TResult = {
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}

export async function getDistrictsDistrictTypesByKeyServer( params: TDistrictsDistrictTypesParams): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictTypesByKey(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/districts/district-types/${params.id}`,
    atomName: `districtTypesAtom`,
  }
}