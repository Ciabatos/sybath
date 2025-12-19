// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getItemsItemsByKey } from "@/db/postgresMainDatabase/schemas/items/items"
import { TItemsItemsParams } from "@/db/postgresMainDatabase/schemas/items/items" 
import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"

// eslint-disable-next-line @typescript-eslint/no-explicit-any
let cachedData: any = null
const CACHE_TTL = 3_000
let lastUpdated = 0

export async function getItemsItemsByKeyServer( params: TItemsItemsParams): Promise<{
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
  atomName: string
}> {
  if (cachedData && Date.now() - lastUpdated < CACHE_TTL) {
    return cachedData
  }

  const getItemsItemsByKeyData = await getItemsItemsByKey(params)

  const data = getItemsItemsByKeyData ? (arrayToObjectKey(["id"], getItemsItemsByKeyData) as TItemsItemsRecordById) : {}

  const result = { raw: getItemsItemsByKeyData, byKey: data, apiPath: `/api/items/items/${params.id}`, atomName: `itemsAtom`  }

  cachedData = result
  lastUpdated = Date.now()

  return result
}
