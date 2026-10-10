// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import {
  TInventoryInventorySlotTypesRecordById,
  TInventoryInventorySlotTypes,
  TInventoryInventorySlotTypesParamsFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/inventorySlotTypes"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { inventorySlotTypesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateInventoryInventorySlotTypes` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const INVENTORYINVENTORYSLOTTYPES_SWR_KEY = () => `/api/inventory/inventory-slot-types`

export function useFetchInventoryInventorySlotTypes() {
  const setInventoryInventorySlotTypes = useSetAtom(inventorySlotTypesAtom)

  const { data } = useSWR<TInventoryInventorySlotTypes[]>(INVENTORYINVENTORYSLOTTYPES_SWR_KEY(), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const inventorySlotTypes = arrayToObjectKey(["id"], data) as TInventoryInventorySlotTypesRecordById
      setInventoryInventorySlotTypes(inventorySlotTypes)
    }
  }, [data, setInventoryInventorySlotTypes])
}

export function useInventoryInventorySlotTypesState() {
  return useAtomValue(inventorySlotTypesAtom)
}
