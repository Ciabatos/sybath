// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TDistrictsDistrictTypes, TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { fetchDistrictsDistrictTypes } from "@/methods/services/districts/fetchDistrictsDistrictTypes"

type TResult = {
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}

export async function getDistrictsDistrictTypesServer(): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictTypes()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/districts/district-types`,
    atomName: `districtTypesAtom`,
  }
}
