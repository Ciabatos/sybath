// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import type { TItemsItemsParams } from "@/db/postgresMainDatabase/schemas/items/items"
import { fetchItemsItemsByKeyService } from "@/methods/services/items/fetchItemsItemsByKeyService"
import type * as AtomsBarrel from "@/store/atoms"

type TResult = {
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: keyof typeof AtomsBarrel
}

export async function getItemsItemsByKeyServer(
  params: TItemsItemsParams,
  options?: { forceFresh?: boolean },
): Promise<TResult> {
  const { record } = await fetchItemsItemsByKeyService(params, { forceFresh: options?.forceFresh })

  return {
    raw: record.raw,
    byKey: record.byKey,
    apiPath: `/api/items/items/${params.id}`,
    atomName: `itemsAtom`,
  }
}
