// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerSkillsRecordBySkillId,
  TPlayerSkillsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerSkills(params: TPlayerSkillsParams) {
  const playerSkills = useAtomValue(playerSkillsAtom)
  const setPlayerSkills = useSetAtom(playerSkillsAtom)

  const { data } = useSWR(`/api/attributes/rpc/get-player-skills/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["skillId"], data) as TPlayerSkillsRecordBySkillId) : {}
      setPlayerSkills(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerSkills])

  return { playerSkills }
}
