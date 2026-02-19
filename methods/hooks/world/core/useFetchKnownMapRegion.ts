// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetMethodFetcher.hbs

"use client"
import {
  TKnownMapRegionRecordByMapTileXMapTileY,
  TKnownMapRegion,
  TKnownMapRegionParams,
} from "@/db/postgresMainDatabase/schemas/world/knownMapRegion"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { knownMapRegionAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchKnownMapRegion(params: TKnownMapRegionParams) {
  const setKnownMapRegion = useSetAtom(knownMapRegionAtom)

  const { data } = useSWR<TKnownMapRegion[]>(
    `/api/world/rpc/get-known-map-region/${params.mapId}/${params.playerId}/${params.regionType}`,
    { refreshInterval: 3000 },
  )

  useEffect(() => {
    if (data) {
      const knownMapRegion = arrayToObjectKey(["mapTileX", "mapTileY"], data) as TKnownMapRegionRecordByMapTileXMapTileY
      setKnownMapRegion(knownMapRegion)
    }
  }, [data, setKnownMapRegion])
}
