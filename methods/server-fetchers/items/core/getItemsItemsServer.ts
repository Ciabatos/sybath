// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getItemsItems } from "@/db/postgresMainDatabase/schemas/items/items"
import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getItemsItemsServer(): Promise<{
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getItemsItemsData = await getItemsItems()

  const data = getItemsItemsData ? (arrayToObjectKey(["id"], getItemsItemsData) as TItemsItemsRecordById) : {}

  const result = { raw: getItemsItemsData, byKey: data, apiPath: `/api/items/items`, atomName: `itemsAtom` }
  
  cachedData = result
  lastUpdated = Date.now()

  return result
}
