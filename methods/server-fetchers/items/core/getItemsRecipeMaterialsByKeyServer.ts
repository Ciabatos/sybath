// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type {
  TItemsRecipeMaterials,
  TItemsRecipeMaterialsRecordById,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import type { TItemsRecipeMaterialsParams } from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { fetchItemsRecipeMaterialsByKeyService } from "@/methods/services/items/fetchItemsRecipeMaterialsByKeyService"

type TResult = {
  raw: TItemsRecipeMaterials[]
  byKey: TItemsRecipeMaterialsRecordById
  apiPath: string
  atomName: string
}

export async function getItemsRecipeMaterialsByKeyServer(
  params: TItemsRecipeMaterialsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchItemsRecipeMaterialsByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/recipe-materials/${params.recipeId}`,
    atomName: `recipeMaterialsAtom`,
  }
}
