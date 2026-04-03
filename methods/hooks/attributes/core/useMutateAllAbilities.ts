// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TAllAbilitiesRecordById,
  TAllAbilitiesParams,
  TAllAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/allAbilities"
import { allAbilitiesAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAllAbilities(params: TAllAbilitiesParams) {
  const { mutate } = useSWRConfig()
  const key = `/api/attributes/rpc/get-all-abilities/${params.playerId}`
  const allAbilities = useAtomValue(allAbilitiesAtom)

  function mutateAllAbilities(optimisticParams?: Partial<TAllAbilities>[]) {
    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    const defaultValues = {
      id: ``,
      name: ``,
      description: ``,
      image: ``,
      value: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAllAbilitiesRecordById

    const optimisticDataMergeWithOldData: TAllAbilitiesRecordById = {
      ...allAbilities,
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

  return { mutateAllAbilities }
}
