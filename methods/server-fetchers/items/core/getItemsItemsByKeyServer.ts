// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import type{ TItemsItemsParams } from "@/db/postgresMainDatabase/schemas/items/items" 
import { fetchItemsItemsByKeyService } from "@/methods/services/items/fetchItemsItemsByKeyService"

type TResult = {
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: string
}

export async function getItemsItemsByKeyServer( params: TItemsItemsParams): Promise<TResult> {
  const { record } = await fetchItemsItemsByKeyService(params)

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/items/${params.id}`,
    atomName: `itemsAtom`,
  }
}