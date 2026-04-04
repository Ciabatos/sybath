// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerRecipeMaterialsParams } from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import type {
  TPlayerRecipeMaterialsRecordById,
  TPlayerRecipeMaterials,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipeMaterials"
import { fetchPlayerRecipeMaterialsService } from "@/methods/services/items/fetchPlayerRecipeMaterialsService"

type TResult = {
  raw: TPlayerRecipeMaterials[]
  byKey: TPlayerRecipeMaterialsRecordById
  apiPath: string
  atomName: string
}

export async function getPlayerRecipeMaterialsServer(
  params: TPlayerRecipeMaterialsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerRecipeMaterialsService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/rpc/get-player-recipe-materials/${params.playerId}/${params.recipeId}`,
    atomName: `playerRecipeMaterialsAtom`,
  }
}
