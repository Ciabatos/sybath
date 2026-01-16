// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TActivePlayerProfileRecordByName, TActivePlayerProfile , TActivePlayerProfileParams  } from "@/db/postgresMainDatabase/schemas/players/activePlayerProfile"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerProfileAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchActivePlayerProfile( params: TActivePlayerProfileParams) {
  const setActivePlayerProfile = useSetAtom(activePlayerProfileAtom)

  const { data } = useSWR<TActivePlayerProfile[]>(`/api/players/rpc/get-active-player-profile/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const activePlayerProfile = arrayToObjectKey(["name"], data) as TActivePlayerProfileRecordByName
      setActivePlayerProfile(activePlayerProfile)
    }
  }, [data, setActivePlayerProfile])
}
