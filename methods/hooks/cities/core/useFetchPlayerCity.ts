// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import { TPlayerCityRecordByCityId, TPlayerCity , TPlayerCityParams  } from "@/db/postgresMainDatabase/schemas/cities/playerCity"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { playerCityAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchPlayerCity( params: TPlayerCityParams) {
  const setPlayerCity = useSetAtom(playerCityAtom)

  const { data } = useSWR<TPlayerCity[]>(`/api/cities/rpc/get-player-city/${params.playerId}`, { refreshInterval: 3000 })

  useEffect(() => {
    if (data) {
      const playerCity = arrayToObjectKey(["cityId"], data) as TPlayerCityRecordByCityId
      setPlayerCity(playerCity)
    }
  }, [data, setPlayerCity])
}
