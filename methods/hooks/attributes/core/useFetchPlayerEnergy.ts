// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TPlayerEnergyRecordByLastRegeneratedAt,
  TPlayerEnergy,
  TPlayerEnergyParams,
} from "@/db/postgresMainDatabase/schemas/attributes/playerEnergy"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerEnergyAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerEnergy(params: TPlayerEnergyParams) {
  const setPlayerEnergy = useSetAtom(playerEnergyAtom)

  const { data } = useSWR<TPlayerEnergy[]>(`/api/attributes/rpc/get-player-energy/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const playerEnergy = arrayToObjectKey(["lastRegeneratedAt"], data) as TPlayerEnergyRecordByLastRegeneratedAt
      setPlayerEnergy(playerEnergy)
    }
  }, [data, setPlayerEnergy])
}

export function usePlayerEnergyState() {
  return useAtomValue(playerEnergyAtom)
}
