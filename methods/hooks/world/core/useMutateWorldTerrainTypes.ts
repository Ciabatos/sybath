// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTable.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import { TWorldTerrainTypesRecordById, TWorldTerrainTypes } from "@/db/postgresMainDatabase/schemas/world/terrainTypes"
import { terrainTypesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateWorldTerrainTypes() {
  const { mutate } = useSWRConfig()
  const key = `/api/world/terrain-types`
  const terrainTypes = useAtomValue(terrainTypesAtom)

  function mutateWorldTerrainTypes(optimisticParams?: Partial<TWorldTerrainTypes>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      moveCost: ``,
      imageUrl: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TWorldTerrainTypesRecordById

    const optimisticDataMergeWithOldData: TWorldTerrainTypesRecordById = {
      ...terrainTypes,
      ...newObj,
    }

    const optimisticDataMergeWithOldDataArray = Object.values(optimisticDataMergeWithOldData)

    mutate(key, () => fetchFresh(key), {
      optimisticData: optimisticDataMergeWithOldDataArray,
      rollbackOnError: true,
      revalidate: false,
      populateCache: true,
    })
  }

  return { mutateWorldTerrainTypes }
}
