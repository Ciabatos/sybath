// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerSkillsRecordBySkillId,
  TPlayerSkillsParams,
  TPlayerSkills,
} from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { playerSkillsAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerSkills(params: TPlayerSkillsParams) {
  const { mutate } = useSWR(`/api/attributes/rpc/get-player-skills/${params.playerId}`)
  const setPlayerSkills = useSetAtom(playerSkillsAtom)
  const playerSkills = useAtomValue(playerSkillsAtom)

  function mutatePlayerSkills(optimisticParams: Partial<TPlayerSkills> | Partial<TPlayerSkills>[]) {
    const params = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    const defaultValues = {
      skillId: ``,
      value: ``,
      name: ``,
    }

    const dataWithDefaults = Object.values(params).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["skillId"], dataWithDefaults) as TPlayerSkillsRecordBySkillId

    const optimisticData: TPlayerSkillsRecordBySkillId = {
      ...playerSkills,
      ...newObj,
    }

    setPlayerSkills(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerSkills }
}
