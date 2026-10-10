// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateMethodFetcher.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TPlayerSkillsRecordBySkillId,
  TPlayerSkillsFetchParams,
  TPlayerSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { PLAYERSKILLS_SWR_KEY } from "@/methods/hooks/attributes/core/useFetchPlayerSkills"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerSkills(params: TPlayerSkillsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = PLAYERSKILLS_SWR_KEY(params)
  const playerSkills = useAtomValue(playerSkillsAtom)

  function mutatePlayerSkills(optimisticParams?: Partial<TPlayerSkills>[]) {
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

    const newObj = arrayToObjectKey(["skillId"], dataWithDefaults) as TPlayerSkillsRecordBySkillId

    const optimisticDataMergeWithOldData: TPlayerSkillsRecordBySkillId = {
      ...playerSkills,
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

  return { mutatePlayerSkills }
}
