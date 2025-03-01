"use client"
import useSWR from "swr"
import { useEffect } from "react"
import { useSetAtom } from "jotai"
import { mapTilesAtom } from "@/store/atoms"

export function useFetchMapTiles() {
  const setMapTiles = useSetAtom(mapTilesAtom)
  const { data, error, isLoading } = useSWR("/api/map-tiles", { refreshInterval: 3000 })

  useEffect(() => {
    setMapTiles(data)
  }, [data, error, isLoading, setMapTiles])
}
