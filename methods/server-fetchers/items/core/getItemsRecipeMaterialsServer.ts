// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type {
  TItemsRecipeMaterials,
  TItemsRecipeMaterialsRecordById,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { fetchItemsRecipeMaterialsService } from "@/methods/services/items/fetchItemsRecipeMaterialsService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TItemsRecipeMaterials[]
  byKey: TItemsRecipeMaterialsRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getItemsRecipeMaterialsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchItemsRecipeMaterialsService({ forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/items/recipe-materials`,
    atomName: `recipeMaterialsAtom`,
  }
}
