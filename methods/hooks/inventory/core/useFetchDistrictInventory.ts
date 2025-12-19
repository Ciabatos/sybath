// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TDistrictInventoryRecordBySlotId, TDistrictInventory , TDistrictInventoryParams  } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { districtInventoryAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchDistrictInventory( params: TDistrictInventoryParams) {
  const districtInventory = useAtomValue(districtInventoryAtom)
  const setDistrictInventory = useSetAtom(districtInventoryAtom)

  const { data } = useSWR<TDistrictInventory[]>(`/api/inventory/rpc/get-district-inventory/${params.districtId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const index = (arrayToObjectKey(["slotId"], data) as TDistrictInventoryRecordBySlotId)
      setDistrictInventory(index)
    }
  }, [data, setDistrictInventory])
  
  return { districtInventory }
}
