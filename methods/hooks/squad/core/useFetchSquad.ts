// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TSquadRecordBySquadId, TSquad, TSquadParams } from "@/db/postgresMainDatabase/schemas/squad/squad"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { squadAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchSquad(params: TSquadParams) {
  const setSquad = useSetAtom(squadAtom)

  const { data } = useSWR<TSquad[]>(`/api/squad/rpc/get-squad/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const squad = arrayToObjectKey(["squadId"], data) as TSquadRecordBySquadId
      setSquad(squad)
    }
  }, [data, setSquad])
}

export function useSquadState() {
  return useAtomValue(squadAtom)
}
