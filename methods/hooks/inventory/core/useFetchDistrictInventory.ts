// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TDistrictInventoryRecordBySlotId,
  TDistrictInventory,
  TDistrictInventoryFetchParams,
} from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateDistrictInventory` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const DISTRICTINVENTORY_SWR_KEY = (params: TDistrictInventoryFetchParams) =>
  params.districtId != null ? `/api/inventory/rpc/get-district-inventory/${params.districtId}` : null

export function useFetchDistrictInventory(params: TDistrictInventoryFetchParams) {
  const setDistrictInventory = useSetAtom(districtInventoryAtom)

  const { data } = useSWR<TDistrictInventory[]>(DISTRICTINVENTORY_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const districtInventory = arrayToObjectKey(["slotId"], data) as TDistrictInventoryRecordBySlotId
      setDistrictInventory(districtInventory)
    }
  }, [data, setDistrictInventory])
}

export function useDistrictInventoryState() {
  return useAtomValue(districtInventoryAtom)
}
