// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getItemsItemsByKey } from "@/db/postgresMainDatabase/schemas/items/items"
import { TItemsItemsParams } from "@/db/postgresMainDatabase/schemas/items/items" 
import type { TItemsItems, TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"

export async function getItemsItemsByKeyServer( params: TItemsItemsParams): Promise<{
  raw: TItemsItems[]
  byKey: TItemsItemsRecordById
  apiPath: string
}> {
  const getItemsItemsByKeyData = await getItemsItemsByKey(params)

  const data = getItemsItemsByKeyData ? (arrayToObjectKey(["id"], getItemsItemsByKeyData) as TItemsItemsRecordById) : {}

  return { raw: getItemsItemsByKeyData, byKey: data, apiPath: `/api/items/items/${params.id}` }
}
