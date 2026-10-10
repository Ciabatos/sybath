// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerSkillsRecordBySkillId,
  TOtherPlayerSkills,
  TOtherPlayerSkillsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutateOtherPlayerSkills` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const OTHERPLAYERSKILLS_SWR_KEY = (params: TOtherPlayerSkillsFetchParams) =>
  params.playerId != null && params.otherPlayerId != null
    ? `/api/attributes/rpc/get-other-player-skills/${params.playerId}/${params.otherPlayerId}`
    : null

export function useFetchOtherPlayerSkills(params: TOtherPlayerSkillsFetchParams) {
  const setOtherPlayerSkills = useSetAtom(otherPlayerSkillsAtom)

  const { data } = useSWR<TOtherPlayerSkills[]>(OTHERPLAYERSKILLS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const otherPlayerSkills = arrayToObjectKey(["skillId"], data) as TOtherPlayerSkillsRecordBySkillId
      setOtherPlayerSkills(otherPlayerSkills)
    }
  }, [data, setOtherPlayerSkills])
}

export function useOtherPlayerSkillsState() {
  return useAtomValue(otherPlayerSkillsAtom)
}
