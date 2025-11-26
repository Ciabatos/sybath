// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getDistrictsDistrictTypes } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"
import type { TDistrictsDistrictTypes, TDistrictsDistrictTypesRecordById } from "@/db/postgresMainDatabase/schemas/districts/districtTypes"


export async function getDistrictsDistrictTypesServer(): Promise<{
  raw: TDistrictsDistrictTypes[]
  byKey: TDistrictsDistrictTypesRecordById
  apiPath: string
}> {
  const getDistrictsDistrictTypesData = await getDistrictsDistrictTypes()

  const data = getDistrictsDistrictTypesData ? (arrayToObjectKey(["id"], getDistrictsDistrictTypesData) as TDistrictsDistrictTypesRecordById) : {}

  return { raw: getDistrictsDistrictTypesData, byKey: data, apiPath: `/api/districts/district-types` }
}
