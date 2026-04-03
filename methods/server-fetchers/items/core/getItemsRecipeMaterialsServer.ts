// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TItemsRecipeMaterials,
  TItemsRecipeMaterialsRecordByRecipeId,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { fetchItemsRecipeMaterialsService } from "@/methods/services/items/fetchItemsRecipeMaterialsService"

type TResult = {
  raw: TItemsRecipeMaterials[]
  byKey: TItemsRecipeMaterialsRecordByRecipeId
  apiPath: string
  atomName: string
}

export async function getItemsRecipeMaterialsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchItemsRecipeMaterialsService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/recipe-materials`,
    atomName: `recipeMaterialsAtom`,
  }
}
