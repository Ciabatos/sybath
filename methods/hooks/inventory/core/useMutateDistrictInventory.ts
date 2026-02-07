// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TDistrictInventoryRecordBySlotId,
  TDistrictInventoryParams,
  TDistrictInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"
import { districtInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateDistrictInventory(params: TDistrictInventoryParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/inventory/rpc/get-district-inventory/${params.districtId}`
  const districtInventory = useAtomValue(districtInventoryAtom)

  function mutateDistrictInventory(optimisticParams?: Partial<TDistrictInventory>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      slotId: ``,
      containerId: ``,
      inventoryContainerTypeId: ``,
      inventorySlotTypeId: ``,
      itemId: ``,
      name: ``,
      quantity: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TDistrictInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TDistrictInventoryRecordBySlotId = {
      ...districtInventory,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, optimisticDataMergeWithOldDataArray, {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateDistrictInventory }
}
