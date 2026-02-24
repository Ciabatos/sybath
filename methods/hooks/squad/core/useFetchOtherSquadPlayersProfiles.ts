// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TOtherSquadPlayersProfilesRecordByName,
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
      const otherSquadPlayersProfiles = arrayToObjectKey(["name"], data) as TOtherSquadPlayersProfilesRecordByName
      setOtherSquadPlayersProfiles(otherSquadPlayersProfiles)
    }
  }, [data, setOtherSquadPlayersProfiles])
}
