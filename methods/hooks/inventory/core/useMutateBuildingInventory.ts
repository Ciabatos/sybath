// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TBuildingInventoryRecordBySlotId,
  TBuildingInventoryParams,
  TBuildingInventory,
} from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"
import { buildingInventoryAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateBuildingInventory(params: TBuildingInventoryParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/inventory/rpc/get-building-inventory/${params.buildingId}`
  const buildingInventory = useAtomValue(buildingInventoryAtom)

  function mutateBuildingInventory(optimisticParams?: Partial<TBuildingInventory>[]) {
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

    const newObj = arrayToObjectKey(["slotId"], dataWithDefaults) as TBuildingInventoryRecordBySlotId

    const optimisticDataMergeWithOldData: TBuildingInventoryRecordBySlotId = {
      ...buildingInventory,
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

  return { mutateBuildingInventory }
}
