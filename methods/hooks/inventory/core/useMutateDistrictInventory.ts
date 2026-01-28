// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import {  TDistrictInventoryParams, TDistrictInventory  } from "@/db/postgresMainDatabase/schemas/inventory/districtInventory"


import useSWR from "swr"
 

export function useMutateDistrictInventory( params: TDistrictInventoryParams) {
  const { mutate } = useSWR<TDistrictInventory[]>(`/api/inventory/rpc/get-district-inventory/${params.districtId}`)
  

  function mutateDistrictInventory(optimisticParams?: Partial<TDistrictInventory> | Partial<TDistrictInventory>[]) {
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

  return { mutateDistrictInventory }
}
