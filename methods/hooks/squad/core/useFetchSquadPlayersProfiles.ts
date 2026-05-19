// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TSquadPlayersProfilesRecordByOtherPlayerId,
  TSquadPlayersProfiles,
  TSquadPlayersProfilesParams,
} from "@/db/postgresMainDatabase/schemas/squad/squadPlayersProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { squadPlayersProfilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchSquadPlayersProfiles(params: TSquadPlayersProfilesParams) {
  const setSquadPlayersProfiles = useSetAtom(squadPlayersProfilesAtom)

  const { data } = useSWR<TSquadPlayersProfiles[]>(`/api/squad/rpc/get-squad-players-profiles/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const squadPlayersProfiles = arrayToObjectKey(
        ["otherPlayerId"],
        data,
      ) as TSquadPlayersProfilesRecordByOtherPlayerId
      setSquadPlayersProfiles(squadPlayersProfiles)
    }
  }, [data, setSquadPlayersProfiles])
}

export function useSquadPlayersProfilesState() {
  return useAtomValue(squadPlayersProfilesAtom)
}
