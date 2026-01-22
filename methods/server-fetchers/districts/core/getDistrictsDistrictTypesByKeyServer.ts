// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TDistrictsDistrictTypes, TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import type{ TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes" 
import { fetchDistrictsDistrictTypesByKeyService } from "@/methods/services/districts/fetchDistrictsDistrictTypesByKeyService"

type TResult = {
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}

export async function getDistrictsDistrictTypesByKeyServer( params: TDistrictsDistrictTypesParams, options?: { forceFresh?: boolean },): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictTypesByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/districts/district-types/${params.id}`,
    atomName: `districtTypesAtom`,
  }
}