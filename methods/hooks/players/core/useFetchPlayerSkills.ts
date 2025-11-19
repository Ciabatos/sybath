// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerSkillsParams, TPlayerSkillsRecordByPlayerId } from "@/db/postgresMainDatabase/schemas/players/playerSkills"
import { arrayToObjectKeyId } from "@/methods/functions/util/converters"
import { playerSkillsAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchPlayerSkills(params: TPlayerSkillsParams) {
  const playerSkills = useAtomValue(playerSkillsAtom)
  const setPlayerSkills = useSetAtom(playerSkillsAtom)

  const { data } = useSWR(`/api/players/rpc/player-skills/${params.playerId}`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKeyId("playerId", data) as TPlayerSkillsRecordByPlayerId) : {}
      setPlayerSkills(index)
      prevDataRef.current = data
    }
  }, [data, setPlayerSkills])

  return { playerSkills }
}
