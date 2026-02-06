// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TWorldLandscapeTypesRecordById,
  TWorldLandscapeTypes,
} from "@/db/postgresMainDatabase/schemas/world/landscapeTypes"
import { landscapeTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldLandscapeTypes() {
  const { mutate } = useSWRConfig()
  const key = `/api/world/landscape-types`
  const landscapeTypes = useAtomValue(landscapeTypesAtom)

  function mutateWorldLandscapeTypes(
    optimisticParams?: Partial<TWorldLandscapeTypes> | Partial<TWorldLandscapeTypes>[],
  ) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    const paramsArray = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      moveCost: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TWorldLandscapeTypesRecordById

    const optimisticDataMergeWithOldData: TWorldLandscapeTypesRecordById = {
      ...landscapeTypes,
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

  return { mutateWorldLandscapeTypes }
}
