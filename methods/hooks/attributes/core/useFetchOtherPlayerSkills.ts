// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerSkillsRecordBySkillId,
  TOtherPlayerSkills,
  TOtherPlayerSkillsParams,
} from "@/db/postgresMainDatabase/schemas/attributes/otherPlayerSkills"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerSkillsAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerSkills(params: TOtherPlayerSkillsParams) {
  const setOtherPlayerSkills = useSetAtom(otherPlayerSkillsAtom)

  const { data } = useSWR<TOtherPlayerSkills[]>(
    `/api/attributes/rpc/get-other-player-skills/${params.playerId}/${params.otherPlayerMaskId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerSkills = arrayToObjectKey(["skillId"], data) as TOtherPlayerSkillsRecordBySkillId
      setOtherPlayerSkills(otherPlayerSkills)
    }
  }, [data, setOtherPlayerSkills])
}
