"use client"
import { cityTilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchCityTiles(cityId: number) {
  const setCityTiles = useSetAtom(cityTilesAtom)
  const { data, error, isLoading } = useSWR(`/api/cities/${cityId}/city-tiles`, { refreshInterval: 3000 })

  useEffect(() => {
    setCityTiles(data)
  }, [data, error, isLoading, setCityTiles])
}
