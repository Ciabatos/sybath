// GENERATED CODE - DO NOT EDIT MANUALLY - hookGetTable.hbs

"use client"
import { TCitiesCityTilesRecordByXY } from "@/db/postgresMainDatabase/schemas/cities/cityTiles"
import { arrayToObjectKey } from "@/methods/functions/util/converters"
import { cityTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCitiesCityTiles() {
  const cityTiles = useAtomValue(cityTilesAtom)
  const setCitiesCityTiles = useSetAtom(cityTilesAtom)

  const { data } = useSWR(`/api/cities/city-tiles`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      const index = data ? (arrayToObjectKey(["x", "y"], data) as TCitiesCityTilesRecordByXY) : {}
      setCitiesCityTiles(index)
      prevDataRef.current = data
    }
  }, [data, setCitiesCityTiles])

  return { cityTiles }
}
