"use client"
import { cityTilesAtom } from "@/store/atoms"
import { useAtomValue, useSetAtom } from "jotai"
import { useEffect, useRef } from "react"
import useSWR from "swr"

export function useFetchCityTiles(cityId: number) {
  const cityTiles = useAtomValue(cityTilesAtom)
  const setCityTiles = useSetAtom(cityTilesAtom)
  const { data } = useSWR(`/api/cities/${cityId}/city-tiles`, { refreshInterval: 3000 })

  const prevDataRef = useRef<unknown>(null)

  useEffect(() => {
    if (data === undefined) return
    if (JSON.stringify(prevDataRef.current) !== JSON.stringify(data)) {
      setCityTiles(data)
      prevDataRef.current = data
    }
  }, [data])

  return { cityTiles }
}
