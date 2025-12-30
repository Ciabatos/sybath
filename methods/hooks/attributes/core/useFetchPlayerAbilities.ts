// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerAbilitiesRecordByAbilityId,
  TPlayerAbilities,
  TPlayerAbilitiesParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerAbilities(params: TPlayerAbilitiesParams) {
  const playerAbilities = useAtomValue(playerAbilitiesAtom)
  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)

  const { data } = useSWR<TPlayerAbilities[]>(`/api/attributes/rpc/get-player-abilities/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const index = arrayToObjectKey(["abilityId"], data) as TPlayerAbilitiesRecordByAbilityId
      setPlayerAbilities(index)
    }
  }, [data, setPlayerAbilities])

  return { playerAbilities }
}
