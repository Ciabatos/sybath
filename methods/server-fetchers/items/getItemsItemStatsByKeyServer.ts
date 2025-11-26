// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKeyServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getItemsItemStatsByKey } from "@/db/postgresMainDatabase/schemas/items/itemStats"
import { TItemsItemStatsParams } from "@/db/postgresMainDatabase/schemas/items/itemStats" 
import type { TItemsItemStats, TItemsItemStatsRecordByItemId } from "@/db/postgresMainDatabase/schemas/items/itemStats"

export async function getItemsItemStatsByKeyServer( params: TItemsItemStatsParams): Promise<{
  raw: TItemsItemStats[]
  byKey: TItemsItemStatsRecordByItemId
  apiPath: string
}> {
  const getItemsItemStatsByKeyData = await getItemsItemStatsByKey(params)

  const data = getItemsItemStatsByKeyData ? (arrayToObjectKey(["itemId"], getItemsItemStatsByKeyData) as TItemsItemStatsRecordByItemId) : {}

  return { raw: getItemsItemStatsByKeyData, byKey: data, apiPath: `/api/items/item-stats/${params.id}` }
}
