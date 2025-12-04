// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TItemsItemsRecordById } from "@/db/postgresMainDatabase/schemas/items/items"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { itemsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchItemsItems() {
  const items = useAtomValue(itemsAtom)
  const setItemsItems = useSetAtom(itemsAtom)

  const { data } = useSWR(`/api/items/items`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["id"], data) as TItemsItemsRecordById) : {}
      setItemsItems(index)
      prevDataRef.current = data
    }
  }, [data, setItemsItems])

  return { items }
}
