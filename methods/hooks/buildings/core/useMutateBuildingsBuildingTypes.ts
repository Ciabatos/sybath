// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import {
  TBuildingsBuildingTypesRecordById,
  TBuildingsBuildingTypes,
} from "@/db/postgresMainDatabase/schemas/buildings/buildingTypes"
import { buildingTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateBuildingsBuildingTypes() {
  const { mutate } = useSWRConfig()
  const key = `/api/buildings/building-types`
  const buildingTypes = useAtomValue(buildingTypesAtom)

  function mutateBuildingsBuildingTypes(optimisticParams?: Partial<TBuildingsBuildingTypes>[]) {
    if (!optimisticParams) {
      mutate(key)
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
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
