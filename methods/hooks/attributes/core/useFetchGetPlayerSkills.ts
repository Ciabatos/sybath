// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TGetPlayerSkillsRecordBySkillId, TGetPlayerSkillsParams } from "@/db/postgresMainDatabase/schemas/attributes/getPlayerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { getPlayerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchGetPlayerSkills(params: TGetPlayerSkillsParams) {
  const getPlayerSkills = useAtomValue(getPlayerSkillsAtom)
  const setGetPlayerSkills = useSetAtom(getPlayerSkillsAtom)

  const { data } = useSWR(`/api/attributes/rpc/get-player-skills/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["skillId"], data) as TGetPlayerSkillsRecordBySkillId) : {}
      setGetPlayerSkills(index)
      prevDataRef.current = data
    }
  }, [data, setGetPlayerSkills])

  return { getPlayerSkills }
}
