// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TBuildingInventoryRecordBySlotId, TBuildingInventory , TBuildingInventoryParams  } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { buildingInventoryAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchBuildingInventory( params: TBuildingInventoryParams) {
  const setBuildingInventory = useSetAtom(buildingInventoryAtom)

  const { data } = useSWR<TBuildingInventory[]>(`/api/inventory/rpc/get-building-inventory/${params.buildingId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const buildingInventory = arrayToObjectKey(["slotId"], data) as TBuildingInventoryRecordBySlotId
      setBuildingInventory(buildingInventory)
    }
  }, [data, setBuildingInventory])
}
