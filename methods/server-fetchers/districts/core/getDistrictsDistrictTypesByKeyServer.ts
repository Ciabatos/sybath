// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictTypesByKey } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import { TDistrictsDistrictTypesParams } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import type {
  TDistrictsDistrictTypes,
  TDistrictsDistrictTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/districts/districtTypes"

export async function getDistrictsDistrictTypesByKeyServer(params: TDistrictsDistrictTypesParams): Promise<{
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
  atomName: string
}> {
  const getDistrictsDistrictTypesByKeyData = await getDistrictsDistrictTypesByKey(params)

  const data = getDistrictsDistrictTypesByKeyData
    ? (arrayToObjectKey(["id"], getDistrictsDistrictTypesByKeyData) as TDistrictsDistrictTypesRecordById)
    : {}

  return {
    raw: getDistrictsDistrictTypesByKeyData,
    byKey: data,
    apiPath: `/api/districts/district-types/${params.id}`,
    atomName: `districtTypesAtom`,
  }
}
