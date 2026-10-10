// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerSkillsRecordBySkillId,
  TPlayerSkills,
  TPlayerSkillsFetchParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

/*
  Wspólny klucz SWR. Eksportowany, bo `useMutatePlayerSkills` musi
  budować DOKŁADNIE tę samą wartość — inaczej SWR widzi dwa różne zasoby,
  a dopasowanie optimistic update'ów po cichu przestaje działać.

  Zwraca `null`, gdy brakuje któregokolwiek parametru. SWR traktuje klucz
  `null` jako "nie pobieraj" i nie wykonuje requestu.
*/
export const PLAYERSKILLS_SWR_KEY = (params: TPlayerSkillsFetchParams) =>
  params.playerId != null ? `/api/attributes/rpc/get-player-skills/${params.playerId}` : null

export function useFetchPlayerSkills(params: TPlayerSkillsFetchParams) {
  const setPlayerSkills = useSetAtom(playerSkillsAtom)

  const { data } = useSWR<TPlayerSkills[]>(PLAYERSKILLS_SWR_KEY(params), {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerSkills = arrayToObjectKey(["skillId"], data) as TPlayerSkillsRecordBySkillId
      setPlayerSkills(playerSkills)
    }
  }, [data, setPlayerSkills])
}

export function usePlayerSkillsState() {
  return useAtomValue(playerSkillsAtom)
}
