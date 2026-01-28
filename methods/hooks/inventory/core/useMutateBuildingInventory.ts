// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {  TBuildingInventoryParams, TBuildingInventory  } from "@/db/postgresMainDatabase/schemas/inventory/buildingInventory"


import useSWR from "swr"
 

export function useMutateBuildingInventory( params: TBuildingInventoryParams) {
  const { mutate } = useSWR<TBuildingInventory[]>(`/api/inventory/rpc/get-building-inventory/${params.buildingId}`)
  

  function mutateBuildingInventory(optimisticParams?: Partial<TBuildingInventory> | Partial<TBuildingInventory>[]) {
    if (!optimisticParams) {
      mutate()
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      slotId: ``,
      containerId: ``,
      itemId: ``,
      name: ``,
      quantity: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    mutate(dataWithDefaults, {
      optimisticData: dataWithDefaults,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateBuildingInventory }
}
