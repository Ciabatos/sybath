"use client"
import { mapTilesAtom } from "@/store/atoms"
import { useSetAtom } from "jotai"
import { useEffect } from "react"
import useSWR from "swr"

export function useFetchMapTiles() {
  const setMapTiles = useSetAtom(mapTilesAtom)
  const { data, error, isLoading } = useSWR("/api/map-tiles", { refreshInterval: 3000 })

  useEffect(() => {
    setMapTiles(data)
  }, [data, error, isLoading, setMapTiles])
}
