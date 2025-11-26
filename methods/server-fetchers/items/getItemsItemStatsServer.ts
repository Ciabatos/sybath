// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableServer.hbs
"use server"

import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getItemsItemStats } from "@/db/postgresMainDatabase/schemas/items/itemStats"
import type { TItemsItemStats, TItemsItemStatsRecordByItemId } from "@/db/postgresMainDatabase/schemas/items/itemStats"


export async function getItemsItemStatsServer(): Promise<{
  raw: TItemsItemStats[]
  byKey: TItemsItemStatsRecordByItemId
  apiPath: string
}> {
  const getItemsItemStatsData = await getItemsItemStats()

  const data = getItemsItemStatsData ? (arrayToObjectKey(["itemId"], getItemsItemStatsData) as TItemsItemStatsRecordByItemId) : {}

  return { raw: getItemsItemStatsData, byKey: data, apiPath: `/api/items/item-stats` }
}
