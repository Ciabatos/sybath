// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId,
  TActivePlayerSquadPlayersProfiles,
  TActivePlayerSquadPlayersProfilesParams,
} from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquadPlayersProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerSquadPlayersProfilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchActivePlayerSquadPlayersProfiles(params: TActivePlayerSquadPlayersProfilesParams) {
  const setActivePlayerSquadPlayersProfiles = useSetAtom(activePlayerSquadPlayersProfilesAtom)

  const { data } = useSWR<TActivePlayerSquadPlayersProfiles[]>(
    `/api/squad/rpc/get-active-player-squad-players-profiles/${params.playerId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const activePlayerSquadPlayersProfiles = arrayToObjectKey(
        ["otherPlayerId"],
        data,
      ) as TActivePlayerSquadPlayersProfilesRecordByOtherPlayerId
      setActivePlayerSquadPlayersProfiles(activePlayerSquadPlayersProfiles)
    }
  }, [data, setActivePlayerSquadPlayersProfiles])
}
