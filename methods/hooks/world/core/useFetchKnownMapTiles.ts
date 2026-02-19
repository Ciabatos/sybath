// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapTilesRecordByXY,
  TKnownMapTiles,
  TKnownMapTilesParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapTilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchKnownMapTiles(params: TKnownMapTilesParams) {
  const setKnownMapTiles = useSetAtom(knownMapTilesAtom)

  const { data } = useSWR<TKnownMapTiles[]>(`/api/world/rpc/get-known-map-tiles/${params.mapId}/${params.playerId}`, {
    refreshInterval: 3000,
  })

  useEffect(() => {
    if (data) {
      const knownMapTiles = arrayToObjectKey(["x", "y"], data) as TKnownMapTilesRecordByXY
      setKnownMapTiles(knownMapTiles)
    }
  }, [data, setKnownMapTiles])
}
