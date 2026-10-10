// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TOtherPlayerSkillsRecordBySkillId,
  TOtherPlayerSkillsFetchParams,
  TOtherPlayerSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { OTHERPLAYERSKILLS_SWR_KEY } from "@/methods/hooks/attributes/core/useFetchOtherPlayerSkills"
import { otherPlayerSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateOtherPlayerSkills(params: TOtherPlayerSkillsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = OTHERPLAYERSKILLS_SWR_KEY(params)
  const otherPlayerSkills = useAtomValue(otherPlayerSkillsAtom)

  function mutateOtherPlayerSkills(optimisticParams?: Partial<TOtherPlayerSkills>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `mapId: ""` — bezsensowną daną, która kompilowała się tylko
      dlatego, że `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`,
      jeśli nie potrzebujesz defaults.
    */
    const defaultValues = {
      skillId: ``,
      value: ``,
      name: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["skillId"], dataWithDefaults) as TOtherPlayerSkillsRecordBySkillId

    const optimisticDataMergeWithOldData: TOtherPlayerSkillsRecordBySkillId = {
      ...otherPlayerSkills,
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

  return { mutateOtherPlayerSkills }
}
