// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerSkillsRecordBySkillId, TPlayerSkills , TPlayerSkillsParams  } from "@/db/postgresMainDatabase/schemas/attributes/playerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerSkillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerSkills( params: TPlayerSkillsParams) {
  const setPlayerSkills = useSetAtom(playerSkillsAtom)

  const { data } = useSWR<TPlayerSkills[]>(`/api/attributes/rpc/get-player-skills/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const playerSkills = arrayToObjectKey(["skillId"], data) as TPlayerSkillsRecordBySkillId
      setPlayerSkills(playerSkills)
    }
  }, [data, setPlayerSkills])
}
