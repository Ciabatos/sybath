// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerAbilitiesRecordByAbilityId,
  TOtherPlayerAbilities,
  TOtherPlayerAbilitiesFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerAbilities"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerAbilitiesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerAbilities` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERABILITIES_SWR_KEY = (params: TOtherPlayerAbilitiesFetchParams) =>
  params.playerId != null && params.otherPlayerId != null
    ? `/api/attributes/rpc/get-other-player-abilities/${params.playerId}/${params.otherPlayerId}`
    : null

export function useFetchOtherPlayerAbilities(params: TOtherPlayerAbilitiesFetchParams) {
  const setOtherPlayerAbilities = useSetAtom(otherPlayerAbilitiesAtom)

  const { data } = useSWR<TOtherPlayerAbilities[]>(OTHERPLAYERABILITIES_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherPlayerAbilities = arrayToObjectKey(["abilityId"], data) as TOtherPlayerAbilitiesRecordByAbilityId
      setOtherPlayerAbilities(otherPlayerAbilities)
    }
  }, [data, setOtherPlayerAbilities])
}

export function useOtherPlayerAbilitiesState() {
  return useAtomValue(otherPlayerAbilitiesAtom)
}
