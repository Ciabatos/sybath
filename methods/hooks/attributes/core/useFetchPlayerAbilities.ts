// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerAbilitiesRecordByAbilityId,
  TPlayerAbilities,
  TPlayerAbilitiesFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerAbilities` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERABILITIES_SWR_KEY = (params: TPlayerAbilitiesFetchParams) =>
  params.playerId != null ? `/api/attributes/rpc/get-player-abilities/${params.playerId}` : null

export function useFetchPlayerAbilities(params: TPlayerAbilitiesFetchParams) {
  const setPlayerAbilities = useSetAtom(playerAbilitiesAtom)

  const { data } = useSWR<TPlayerAbilities[]>(PLAYERABILITIES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerAbilities = arrayToObjectKey(["abilityId"], data) as TPlayerAbilitiesRecordByAbilityId
      setPlayerAbilities(playerAbilities)
    }
  }, [data, setPlayerAbilities])
}

export function usePlayerAbilitiesState() {
  return useAtomValue(playerAbilitiesAtom)
}
