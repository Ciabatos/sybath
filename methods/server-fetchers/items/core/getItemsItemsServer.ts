// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { fetchItemsItems } from "@/methods/services/items/fetchItemsItems"

type TResult = {
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: string
}

export async function getItemsItemsServer(): Promise<TResult> {
  const { record } = await fetchItemsItems()

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/items`,
    atomName: `itemsAtom`,
  }
}
