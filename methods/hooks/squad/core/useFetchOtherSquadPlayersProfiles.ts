// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherSquadPlayersProfilesRecordByOtherPlayerId,
  TOtherSquadPlayersProfiles,
  TOtherSquadPlayersProfilesParams,
} from "@/db/postgresMainDatabase/schemas/squad/otherSquadPlayersProfiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { otherSquadPlayersProfilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchOtherSquadPlayersProfiles(params: TOtherSquadPlayersProfilesParams) {
  const setOtherSquadPlayersProfiles = useSetAtom(otherSquadPlayersProfilesAtom)

  const { data } = useSWR<TOtherSquadPlayersProfiles[]>(
    `/api/squad/rpc/get-other-squad-players-profiles/${params.playerId}/${params.squadId}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const otherSquadPlayersProfiles = arrayToObjectKey(
        ["otherPlayerId"],
        data,
      ) as TOtherSquadPlayersProfilesRecordByOtherPlayerId
      setOtherSquadPlayersProfiles(otherSquadPlayersProfiles)
    }
  }, [data, setOtherSquadPlayersProfiles])
}
