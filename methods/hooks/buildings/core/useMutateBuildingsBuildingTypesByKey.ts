// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TBuildingsBuildingTypesRecordById,
  TBuildingsBuildingTypesParams,
  TBuildingsBuildingTypes,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { buildingTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateBuildingsBuildingTypes(params: TBuildingsBuildingTypesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/buildings/building-types/${params.id}`
  const buildingTypes = useAtomValue(buildingTypesAtom)

  function mutateBuildingsBuildingTypes(
    optimisticParams?: Partial<TBuildingsBuildingTypes> | Partial<TBuildingsBuildingTypes>[],
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
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = paramsArray.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TBuildingsBuildingTypesRecordById

    const optimisticDataMergeWithOldData: TBuildingsBuildingTypesRecordById = {
      ...buildingTypes,
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

  return { mutateBuildingsBuildingTypes }
}
