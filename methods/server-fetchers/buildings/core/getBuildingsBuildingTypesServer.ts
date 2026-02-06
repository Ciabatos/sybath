// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TBuildingsBuildingTypes,
  TBuildingsBuildingTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { fetchBuildingsBuildingTypesService } from "@/methods/services/buildings/fetchBuildingsBuildingTypesService"

type TResult = {
  raw: TBuildingsBuildingTypes[]
  byKey: TBuildingsBuildingTypesRecordById
  apiPath: string
  atomName: string
}

export async function getBuildingsBuildingTypesServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchBuildingsBuildingTypesService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/buildings/building-types`,
    atomName: `buildingTypesAtom`,
  }
}
