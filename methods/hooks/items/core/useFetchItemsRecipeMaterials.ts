// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TItemsRecipeMaterialsRecordById,
  TItemsRecipeMaterials,
  TItemsRecipeMaterialsParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/items/recipeMaterials"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { recipeMaterialsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateItemsRecipeMaterials` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const ITEMSRECIPEMATERIALS_SWR_KEY = () => `/api/items/recipe-materials`

export function useFetchItemsRecipeMaterials() {
  const setItemsRecipeMaterials = useSetAtom(recipeMaterialsAtom)

  const { data } = useSWR<TItemsRecipeMaterials[]>(ITEMSRECIPEMATERIALS_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const recipeMaterials = arrayToObjectKey(["id"], data) as TItemsRecipeMaterialsRecordById
      setItemsRecipeMaterials(recipeMaterials)
    }
  }, [data, setItemsRecipeMaterials])
}

export function useItemsRecipeMaterialsState() {
  return useAtomValue(recipeMaterialsAtom)
}
