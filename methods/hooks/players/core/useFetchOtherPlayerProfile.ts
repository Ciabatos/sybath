// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherPlayerProfileRecordByName,
  TOtherPlayerProfile,
  TOtherPlayerProfileParams,
} from "@/db/postgresMainDatabase/schemas/players/otherPlayerProfile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherPlayerProfileAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherPlayerProfile(params: TOtherPlayerProfileParams) {
  const setOtherPlayerProfile = useSetAtom(otherPlayerProfileAtom)

  const { data } = useSWR<TOtherPlayerProfile[]>(
    `/api/players/rpc/get-other-player-profile/${params.playerId}/${params.otherPlayerMaskId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherPlayerProfile = arrayToObjectKey(["name"], data) as TOtherPlayerProfileRecordByName
      setOtherPlayerProfile(otherPlayerProfile)
    }
  }, [data, setOtherPlayerProfile])
}
