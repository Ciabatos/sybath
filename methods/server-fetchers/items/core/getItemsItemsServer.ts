// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getItemsItems } from "@/db/postgresMainDatabase/schemas/items/items"
import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"

export async function getItemsItemsServer(): Promise<{
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: string
}> {
  const getItemsItemsData = await getItemsItems()

  const data = getItemsItemsData ? (arrayToObjectKey(["id"], getItemsItemsData) as TItemsItemsRecordById) : {}

  return { raw: getItemsItemsData, byKey: data, apiPath: `/api/items/items`, atomName: `itemsAtom` }
}
