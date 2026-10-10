// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TItemsItemsRecordById,
  TItemsItems,
  TItemsItemsParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/items/items"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { itemsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateItemsItems` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ITEMSITEMS_SWR_KEY = () => `/api/items/items`

export function useFetchItemsItems() {
  const setItemsItems = useSetAtom(itemsAtom)

  const { data } = useSWR<TItemsItems[]>(ITEMSITEMS_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const items = arrayToObjectKey(["id"], data) as TItemsItemsRecordById
      setItemsItems(items)
    }
  }, [data, setItemsItems])
}

export function useItemsItemsState() {
  return useAtomValue(itemsAtom)
}
