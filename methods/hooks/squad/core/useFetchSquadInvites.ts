// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TSquadInvitesRecordById,
  TSquadInvites,
  TSquadInvitesParams,
} from "@/db/postgresMainDatabase/schemas/squad/squadInvites"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { squadInvitesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchSquadInvites(params: TSquadInvitesParams) {
  const setSquadInvites = useSetAtom(squadInvitesAtom)

  const { data } = useSWR<TSquadInvites[]>(`/api/squad/rpc/get-squad-invites/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const squadInvites = arrayToObjectKey(["id"], data) as TSquadInvitesRecordById
      setSquadInvites(squadInvites)
    }
  }, [data, setSquadInvites])
}

export function useSquadInvitesState() {
  return useAtomValue(squadInvitesAtom)
}
