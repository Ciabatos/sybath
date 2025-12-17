// GENERATED CODE - DO NOT EDIT MANUALLY - hookMutateMethodFetcher.hbs
"use client"

import {
  TPlayerAbilitiesRecordByAbilityId,
  TPlayerAbilitiesParams,
  TPlayerAbilities,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useSetAtom, useAtomValue } from "jotai"
import useSWR from "swr"
import { arrayToObjectKey } from "@/methods/functions/util/converters"

export function useMutatePlayerAbilities(params: TPlayerAbilitiesParams) {
  const { mutate } = useSWR(`/api/attributes/rpc/get-player-abilities/${params.playerId}`)
  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)
  const playerAbilities = useAtomValue(playerAbilitiesAtom)

  function mutatePlayerAbilities(optimisticParams: Partial<TPlayerAbilities> | Partial<TPlayerAbilities>[]) {
    const params = Array.isArray(optimisticParams) ? optimisticParams : [optimisticParams]

    const defaultValues = {
      abilityId: ``,
      value: ``,
      name: ``,
    }

    const dataWithDefaults = Object.values(params).map((val) => ({
      ...defaultValues,
      ...val,
    }))

    const newObj = arrayToObjectKey(["abilityId"], dataWithDefaults) as TPlayerAbilitiesRecordByAbilityId

    const optimisticData: TPlayerAbilitiesRecordByAbilityId = {
      ...playerAbilities,
      ...newObj,
    }

    setPlayerAbilities(optimisticData)

    mutate(undefined, {
      optimisticData,
      rollbackOnError: true,
      revalidate: true,
      populateCache: true,
    })
  }

  return { mutatePlayerAbilities }
}
