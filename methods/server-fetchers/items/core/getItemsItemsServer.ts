// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { fetchItemsItemsService } from "@/methods/services/items/fetchItemsItemsService"

type TResult = {
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: string
}

export async function getItemsItemsServer(options?: { forceFresh?: boolean }): Promise<TResult> {
  const { record } = await fetchItemsItemsService({ forceFresh: options?.forceFresh })

  return {
    raw: record!.raw,
    byKey: record!.byKey,
    apiPath: `/api/items/items`,
    atomName: `itemsAtom`,
  }
}
