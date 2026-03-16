// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TActivePlayerSquadRecordBySquadId,
  TActivePlayerSquad,
  TActivePlayerSquadParams,
} from "@/db/postgresMainDatabase/schemas/squad/activePlayerSquad"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { activePlayerSquadAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchActivePlayerSquad(params: TActivePlayerSquadParams) {
  const setActivePlayerSquad = useSetAtom(activePlayerSquadAtom)

  const { data } = useSWR<TActivePlayerSquad[]>(`/api/squad/rpc/get-active-player-squad/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const activePlayerSquad = arrayToObjectKey(["squadId"], data) as TActivePlayerSquadRecordBySquadId
      setActivePlayerSquad(activePlayerSquad)
    }
  }, [data, setActivePlayerSquad])
}

export function useActivePlayerSquadState() {
  return useAtomValue(activePlayerSquadAtom)
}
