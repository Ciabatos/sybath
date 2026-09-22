// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TAllAbilitiesParams } from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import type { TAllAbilitiesRecordById, TAllAbilities } from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import { fetchAllAbilitiesService } from "@/methods/services/attributes/fetchAllAbilitiesService"

type TResult = {
  raw: TAllAbilities[]
  byKey: TAllAbilitiesRecordById
  apiPath: string
  atomName: string
}

export async function getAllAbilitiesServer(
  params: TAllAbilitiesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchAllAbilitiesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/attributes/rpc/get-all-abilities/${params.playerId}`,
    atomName: `allAbilitiesAtom`,
  }
}
