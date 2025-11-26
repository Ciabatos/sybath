// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TItemsItemStatsRecordByItemId, TItemsItemStatsParams } from "@/db/postgresMainDatabase/schemas/items/itemStats"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { itemStatsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchItemsItemStatsByKey( params: TItemsItemStatsParams ) {
  const itemStats = useAtomValue(itemStatsAtom)
  const setItemsItemStats = useSetAtom(itemStatsAtom)
  
  const { data } = useSWR(`/api/items/item-stats/${params.id}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["itemId"], data) as TItemsItemStatsRecordByItemId) : {}
      setItemsItemStats(index)
      prevDataRef.current = data
    }
  }, [data, setItemsItemStats])

  return { itemStats }
}
