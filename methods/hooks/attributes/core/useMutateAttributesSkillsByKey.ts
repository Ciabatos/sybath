// GENERATED CODE - SHOULD BE EDITED MANUALLY TO END CONFIGURATION - hookMutateTableByKey.hbs
"use client"

import { useSWRConfig } from "swr"
import { fetchFresh } from "@/providers/swr-fetchers"
import {
  TAttributesSkillsRecordById,
  TAttributesSkillsParamsFetchParams,
  TAttributesSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/skills"
import { ATTRIBUTESSKILLS_SWR_KEY_BY_KEY } from "@/methods/hooks/attributes/core/useFetchAttributesSkillsByKey"
import { skillsAtom } from "@/store/atoms"
import { useAtomValue } from "jotai"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutateAttributesSkills(params: TAttributesSkillsParamsFetchParams) {
  const { mutate } = useSWRConfig()
  const key = ATTRIBUTESSKILLS_SWR_KEY_BY_KEY(params)
  const skills = useAtomValue(skillsAtom)

  function mutateAttributesSkills(optimisticParams?: Partial<TAttributesSkills>[]) {
    if (!key) return

    if (!optimisticParams) {
      mutate(key, () => fetchFresh(key))
      return
    }

    //MANUAL CODE - START

    /*
      Uzupełnij wartości domyślne dla `optimisticParams`. Wcześniej generator
      wpisywał tu `` (pusty string) dla KAŻDEGO pola, co dla pól liczbowych
      oznaczało `id: ""` — bezsensowną daną, kompilującą się tylko dlatego, że
      `Partial<T>` maskuje typ. Uzupełniaj ręcznie albo zostaw `{}`.
    */
    const defaultValues = {
      id: ``,
      name: ``,
      description: ``,
      image: ``,
    }

    //MANUAL CODE - END

    const dataWithDefaults = optimisticParams.map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["id"], dataWithDefaults) as TAttributesSkillsRecordById

    const optimisticDataMergeWithOldData: TAttributesSkillsRecordById = {
      ...skills,
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

  return { mutateAttributesSkills }
}
