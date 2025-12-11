// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTableByKey.hbs

"use client"
import {
  TAttributesPlayerSkillsRecordByPlayerId,
  TAttributesPlayerSkillsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchAttributesPlayerSkillsByKey(params: TAttributesPlayerSkillsParams) {
  const playerSkills = useAtomValue(playerSkillsAtom)
  const setAttributesPlayerSkills = useSetAtom(playerSkillsAtom)

  const { data } = useSWR(`/api/attributes/player-skills/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["playerId"], data) as TAttributesPlayerSkillsRecordByPlayerId) : {}
      setAttributesPlayerSkills(index)
      prevDataRef.current = data
    }
  }, [data, setAttributesPlayerSkills])

  return { playerSkills }
}
