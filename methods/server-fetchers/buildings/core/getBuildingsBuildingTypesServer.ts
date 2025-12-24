// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TBuildingsBuildingTypes, TBuildingsBuildingTypesRecordById } from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { fetchBuildingsBuildingTypes } from "@/methods/services/buildings/fetchBuildingsBuildingTypes"

type TResult = {
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingTypesServer(): Promise<TResult> {
  const { record } = await fetchBuildingsBuildingTypes()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/building-types`,
    atomName: `buildingTypesAtom`,
  }
}
