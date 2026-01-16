// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import { TItemsItemsRecordById, TItemsItems, TItemsItemsParams } from "@/db/postgresMainDatabase/schemas/items/items"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { itemsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchItemsItemsByKey( params: TItemsItemsParams ) {
  const setItemsItems = useSetAtom(itemsAtom)
  
  const { data } = useSWR<TItemsItems[]>(`/api/items/items/${params.id}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const items = arrayToObjectKey(["id"], data) as TItemsItemsRecordById
      setItemsItems(items)
    }
  }, [data, setItemsItems])
}
