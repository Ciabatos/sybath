// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TActivePlayerSwitchProfilesRecordByName, TActivePlayerSwitchProfiles , TActivePlayerSwitchProfilesParams  } from "@/db/postgresMainDatabase/schemas/players/activePlayerSwitchProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerSwitchProfilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchActivePlayerSwitchProfiles( params: TActivePlayerSwitchProfilesParams) {
  const setActivePlayerSwitchProfiles = useSetAtom(activePlayerSwitchProfilesAtom)

  const { data } = useSWR<TActivePlayerSwitchProfiles[]>(`/api/players/rpc/get-active-player-switch-profiles/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const activePlayerSwitchProfiles = arrayToObjectKey(["name"], data) as TActivePlayerSwitchProfilesRecordByName
      setActivePlayerSwitchProfiles(activePlayerSwitchProfiles)
    }
  }, [data, setActivePlayerSwitchProfiles])
}
