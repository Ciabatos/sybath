// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TItemsItemsRecordById, TItemsItems } from "@/db/postgresMainDatabase/schemas/items/items"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { itemsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchItemsItems() {
  const items = useAtomValue(itemsAtom)
  const setItemsItems = useSetAtom(itemsAtom)
  
  const { data } = useSWR<TItemsItems[]>(`/api/items/items`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["id"], data) as TItemsItemsRecordById)
      setItemsItems(index)
    }
  }, [data, setItemsItems])

  return { items }
}
