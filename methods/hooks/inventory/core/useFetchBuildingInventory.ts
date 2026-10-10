// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TBuildingInventoryRecordBySlotId,
  TBuildingInventory,
  TBuildingInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateBuildingInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const BUILDINGINVENTORY_SWR_KEY = (params: TBuildingInventoryFetchParams) =>
  params.buildingId != null ? `/api/inventory/rpc/get-building-inventory/${params.buildingId}` : null

export function useFetchBuildingInventory(params: TBuildingInventoryFetchParams) {
  const setBuildingInventory = useSetAtom(buildingInventoryAtom)

  const { data } = useSWR<TBuildingInventory[]>(BUILDINGINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const buildingInventory = arrayToObjectKey(["slotId"], data) as TBuildingInventoryRecordBySlotId
      setBuildingInventory(buildingInventory)
    }
  }, [data, setBuildingInventory])
}

export function useBuildingInventoryState() {
  return useAtomValue(buildingInventoryAtom)
}
