// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcherServer.hbs
"use server"

import type { TPlayerRecipesParams } from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import type {
  TPlayerRecipesRecordByItemId,
  TPlayerRecipes,
} from "@/db/postgresMainDatabase/schemas/items/playerRecipes"
import { fetchPlayerRecipesService } from "@/methods/services/items/fetchPlayerRecipesService"

type TResult = {
  raw: TPlayerRecipes[]
  byKey: TPlayerRecipesRecordByItemId
  apiPath: string
  atomName: string
}

export async function getPlayerRecipesServer(
  params: TPlayerRecipesParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchPlayerRecipesService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/rpc/get-player-recipes/${params.playerId}`,
    atomName: `playerRecipesAtom`,
  }
}
