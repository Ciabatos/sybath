// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TDistrictsDistrictTypes,
  TDistrictsDistrictTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { fetchDistrictsDistrictTypesService } from "@/methods/services/districts/fetchDistrictsDistrictTypesService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getDistrictsDistrictTypesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchDistrictsDistrictTypesService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/districts/district-types`,
    atomName: `districtTypesAtom`,
  }
}
