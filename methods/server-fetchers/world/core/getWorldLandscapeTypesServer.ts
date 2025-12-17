// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getWorldLandscapeTypes } from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import type {
  TWorldLandscapeTypes,
  TWorldLandscapeTypesRecordById,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"

export async function getWorldLandscapeTypesServer(): Promise<{
  raw: TWorldLandscapeTypes[]
  byKey: TWorldLandscapeTypesRecordById
  apiPath: string
  atomName: string
}> {
  const getWorldLandscapeTypesData = await getWorldLandscapeTypes()

  const data = getWorldLandscapeTypesData
    ? (arrayToObjectKey(["id"], getWorldLandscapeTypesData) as TWorldLandscapeTypesRecordById)
    : {}

  return {
    raw: getWorldLandscapeTypesData,
    byKey: data,
    apiPath: `/api/world/landscape-types`,
    atomName: `landscapeTypesAtom`,
  }
}
